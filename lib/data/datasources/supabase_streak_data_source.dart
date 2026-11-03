import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/dates.dart';
import '../models/streak_data.dart';
import 'streak_data_source.dart';

/// Calcula la racha del usuario consultando `daily_summaries`.
///
/// Un día cuenta para la racha si tiene una fila con `all_done = true`,
/// lo que significa que el usuario completó todos sus hábitos de ese día.
class SupabaseStreakDataSource implements StreakDataSource {
  SupabaseStreakDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<StreakData> getStreak() {
    return _request('No se pudo calcular tu racha', () async {
      final since = DateTime.now().subtract(const Duration(days: 365));

      final rows = await _client
          .from('daily_summaries')
          .select('summary_date')
          .eq('user_id', _userId)
          .eq('all_done', true)
          .gte('summary_date', isoDate(since))
          .order('summary_date', ascending: false);

      // Días donde el usuario completó todos los hábitos.
      final completedDays = <DateTime>{
        for (final row in rows)
          dateOnly(DateTime.parse(row['summary_date'] as String)),
      };

      // Calcula la racha continua hacia atrás desde hoy.
      final today = dateOnly(DateTime.now());
      var streak = 0;
      var cursor = today;

      while (completedDays.contains(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }

      // Si hoy no está completo aún, la racha puede venir de ayer.
      if (streak == 0) {
        cursor = today.subtract(const Duration(days: 1));
        while (completedDays.contains(cursor)) {
          streak++;
          cursor = cursor.subtract(const Duration(days: 1));
        }
      }

      // Los días a marcar en el calendario son TODOS los días completados
      // del historial (no solo la racha actual), para mostrar el progreso pasado.
      return StreakData(currentStreak: streak, streakDays: completedDays);
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
      throw StreakDataException(errorMessage);
    } catch (e) {
      debugPrint('Error de conexión (racha): $e');
      throw StreakDataException('Revisa tu conexión e inténtalo de nuevo');
    }
  }
}
