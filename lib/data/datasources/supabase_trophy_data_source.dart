import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trophy.dart';
import 'trophy_data_source.dart';

class SupabaseTrophyDataSource implements TrophyDataSource {
  SupabaseTrophyDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Trophy>> getAllTrophies() {
    return _request('No se pudieron cargar los trofeos', () async {
      final rows = await _client.from('trophies').select().order('trophy_name');

      return rows.map(Trophy.fromMap).toList();
    });
  }

  @override
  Future<List<EarnedTrophy>> getEarnedTrophies() {
    return _request('No se pudieron cargar tus trofeos ganados', () async {
      final userId = _userId;

      // Trae los trofeos ganados junto con la info del trofeo (join).
      final rows = await _client
          .from('trophies_per_user')
          .select('earned_at, trophies(trophy_id, trophy_name, trophy_key)')
          .eq('user_id', userId)
          .order('earned_at', ascending: false);

      return [
        for (final row in rows)
          EarnedTrophy.fromMap(
            row,
            Trophy.fromMap(row['trophies'] as Map<String, dynamic>),
          ),
      ];
    });
  }

  @override
  Future<EarnedTrophy?> awardTrophy(String trophyId) {
    return _request('No se pudo otorgar el trofeo', () async {
      final userId = _userId;

      // Verifica si ya lo tiene para no duplicar.
      final existing = await _client
          .from('trophies_per_user')
          .select('earned_at')
          .eq('user_id', userId)
          .eq('trophy_id', trophyId)
          .maybeSingle();

      if (existing != null) return null;

      // Inserta el registro de trofeo ganado.
      await _client.from('trophies_per_user').insert({
        'user_id': userId,
        'trophy_id': trophyId,
        'earned_at': DateTime.now().toIso8601String(),
      });

      // Recupera la info completa del trofeo para devolver el EarnedTrophy.
      final trophyRow = await _client
          .from('trophies')
          .select()
          .eq('trophy_id', trophyId)
          .single();

      final earnedRow = await _client
          .from('trophies_per_user')
          .select('earned_at')
          .eq('user_id', userId)
          .eq('trophy_id', trophyId)
          .single();

      return EarnedTrophy.fromMap(earnedRow, Trophy.fromMap(trophyRow));
    });
  }

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay una sesión iniciada');
    return user.id;
  }

  Future<T> _request<T>(String errorMessage, Future<T> Function() query) async {
    try {
      return await query();
    } on PostgrestException catch (e) {
      debugPrint('Supabase error ${e.code}: ${e.message}');
      throw TrophyDataException(errorMessage);
    } catch (e) {
      debugPrint('Error de conexión (trofeos): $e');
      throw TrophyDataException('Revisa tu conexión e inténtalo de nuevo');
    }
  }
}
