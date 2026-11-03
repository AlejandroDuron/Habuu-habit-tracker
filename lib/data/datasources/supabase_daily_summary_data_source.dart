import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/dates.dart';
import 'daily_summary_data_source.dart';

class SupabaseDailySummaryDataSource implements DailySummaryDataSource {
  SupabaseDailySummaryDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<void> markDayComplete(DateTime day) async {
    try {
      await _client.from('daily_summaries').upsert({
        'user_id': _userId,
        'summary_date': isoDate(day),
        'all_done': true,
      }, onConflict: 'user_id,summary_date');
    } on PostgrestException catch (e) {
      debugPrint(
        'Supabase error al guardar resumen diario ${e.code}: ${e.message}',
      );
      throw const DailySummaryException(
        'No se pudo registrar el día como completado',
      );
    } catch (e) {
      debugPrint('Error de conexión (daily_summaries): $e');
      throw const DailySummaryException(
        'Revisa tu conexión e inténtalo de nuevo',
      );
    }
  }

  @override
  Future<Set<DateTime>> getCompletedDays({required DateTime since}) async {
    try {
      final rows = await _client
          .from('daily_summaries')
          .select('summary_date')
          .eq('user_id', _userId)
          .eq('all_done', true)
          .gte('summary_date', isoDate(since));

      return {
        for (final row in rows)
          dateOnly(DateTime.parse(row['summary_date'] as String)),
      };
    } on PostgrestException catch (e) {
      debugPrint('Supabase error al leer resúmenes ${e.code}: ${e.message}');
      throw const DailySummaryException('No se pudo cargar el historial');
    } catch (e) {
      debugPrint('Error de conexión (daily_summaries): $e');
      throw const DailySummaryException(
        'Revisa tu conexión e inténtalo de nuevo',
      );
    }
  }

  @override
  Future<int> getTotalCompletedDays() async {
    try {
      // Cuenta todas las filas con all_done = true del usuario.
      final rows = await _client
          .from('daily_summaries')
          .select('summary_date')
          .eq('user_id', _userId)
          .eq('all_done', true);

      return rows.length;
    } on PostgrestException catch (e) {
      debugPrint(
        'Supabase error al contar días completados ${e.code}: ${e.message}',
      );
      throw const DailySummaryException(
        'No se pudo contar el total de días completados',
      );
    } catch (e) {
      debugPrint('Error de conexión (daily_summaries total): $e');
      throw const DailySummaryException(
        'Revisa tu conexión e inténtalo de nuevo',
      );
    }
  }

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay una sesión iniciada');
    return user.id;
  }
}
