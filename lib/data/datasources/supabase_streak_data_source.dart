import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/dates.dart';
import '../models/streak_data.dart';
import 'streak_data_source.dart';

/// Calcula la racha del usuario consultando `habit_logs`.
///
/// Un día cuenta para la racha si el usuario completó (status = 'done')
/// al menos un hábito ese día. Se calcula hacia atrás desde hoy.
class SupabaseStreakDataSource implements StreakDataSource {
  SupabaseStreakDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<StreakData> getStreak() {
    return _request('No se pudo calcular tu racha', () async {
      final userId = _userId;

      // Trae las fechas con al menos un hábito completado (done),
      // de los últimos 365 días para no pedir demasiados datos.
      final since = DateTime.now().subtract(const Duration(days: 365));
      final rows = await _client
          .from('habit_logs')
          .select('log_date, habits!inner(user_id)')
          .eq('habits.user_id', userId)
          .eq('status', 'done')
          .gte('log_date', isoDate(since))
          .order('log_date', ascending: false);

      // Extrae las fechas únicas (solo la parte de fecha, sin hora).
      final doneDays = <DateTime>{
        for (final row in rows)
          dateOnly(DateTime.parse(row['log_date'] as String)),
      };

      // Calcula la racha continua hacia atrás desde hoy.
      final today = dateOnly(DateTime.now());
      var streak = 0;
      var cursor = today;

      while (doneDays.contains(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }

      // Si hoy no tiene hábitos hechos, la racha puede venir de ayer.
      if (streak == 0) {
        final yesterday = today.subtract(const Duration(days: 1));
        cursor = yesterday;
        while (doneDays.contains(cursor)) {
          streak++;
          cursor = cursor.subtract(const Duration(days: 1));
        }
      }

      // Los días de racha son los que forman la cadena continua.
      final streakStart = streak > 0
          ? today.subtract(Duration(days: streak - 1))
          : today;
      final streakDays = <DateTime>{
        for (var i = 0; i < streak; i++)
          streakStart.add(Duration(days: i)),
      };

      return StreakData(
        currentStreak: streak,
        streakDays: streakDays,
      );
    });
  }

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay una sesión iniciada');
    return user.id;
  }

  Future<T> _request<T>(
    String errorMessage,
    Future<T> Function() query,
  ) async {
    try {
      return await query();
    } on PostgrestException catch (e) {
      debugPrint('Supabase error ${e.code}: ${e.message}');
      throw StreakDataException(errorMessage);
    } catch (e) {
      debugPrint('Error de conexión (racha): $e');
      throw StreakDataException(
        'Revisa tu conexión e inténtalo de nuevo',
      );
    }
  }
}
