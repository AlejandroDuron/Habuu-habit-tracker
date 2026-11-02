import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/dates.dart';
import '../models/habit_log.dart';
import '../models/home_habit.dart';
import 'home_data_source.dart';

class SupabaseHomeDataSource implements HomeDataSource {
  SupabaseHomeDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<HomeHabit>> getActiveHabits() {
    return _request('No se pudieron cargar tus hábitos', () async {
      final rows = await _client
          .from('habits')
          .select()
          .eq('user_id', _userId)
          .isFilter('deleted_at', null)
          .order('created_at');

      return rows.map(HomeHabit.fromMap).toList();
    });
  }

  @override
  Future<List<HabitLog>> getLogsOn(DateTime day) {
    return _request('No se pudo cargar tu progreso de hoy', () async {
      _requireSession();

      final rows = await _client
          .from('habit_logs')
          .select()
          .eq('log_date', isoDate(day));

      return rows.map(HabitLog.fromMap).toList();
    });
  }

  @override
  Future<HabitLog> saveLog({
    required String habitId,
    required DateTime day,
    required LogStatus status,
    String? evidencePath,
  }) {
    return _request('No se pudo guardar tu hábito', () async {
      _requireSession();

      final row = await _client
          .from('habit_logs')
          .upsert({
            'habit_id': habitId,
            'log_date': isoDate(day),
            'status': status.name,
            'evidence_path': evidencePath,
          }, onConflict: 'habit_id,log_date')
          .select()
          .single();

      return HabitLog.fromMap(row);
    });
  }

  /// Id del usuario con sesión iniciada.
  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw const NotSignedInException();
    return user.id;
  }

  void _requireSession() => _userId;

  Future<T> _request<T>(String errorMessage, Future<T> Function() query) async {
    try {
      return await query();
    } on PostgrestException catch (e) {
      debugPrint('Supabase respondió con error ${e.code}: ${e.message}');
      throw HomeDataException(errorMessage);
    } on NotSignedInException {
      rethrow;
    } on TypeError catch (e) {
      debugPrint('Dato inesperado de Supabase: $e');
      throw HomeDataException(errorMessage);
    } catch (e) {
      debugPrint('Error de conexión con Supabase: $e');
      throw const HomeDataException('Revisa tu conexión e inténtalo de nuevo');
    }
  }
}
