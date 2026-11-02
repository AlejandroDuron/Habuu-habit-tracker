import '../models/streak_data.dart';

abstract interface class StreakDataSource {
  /// Calcula la racha actual del usuario a partir de sus registros en `habit_logs`.
  Future<StreakData> getStreak();
}

/// Error al calcular la racha, con un mensaje listo para mostrarse.
class StreakDataException implements Exception {
  const StreakDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
