abstract interface class DailySummaryDataSource {
  /// Marca el día [day] como completado (todos los hábitos hechos).
  /// Hace upsert, así que es seguro llamarlo más de una vez.
  Future<void> markDayComplete(DateTime day);

  /// Trae todas las fechas marcadas como completadas desde [since].
  Future<Set<DateTime>> getCompletedDays({required DateTime since});

  /// Devuelve el total de días completados acumulados del usuario (sin límite de fecha).
  /// Se usa para evaluar el trofeo streak_300.
  Future<int> getTotalCompletedDays();
}

/// Error al leer o escribir el resumen diario.
class DailySummaryException implements Exception {
  const DailySummaryException(this.message);

  final String message;

  @override
  String toString() => message;
}
