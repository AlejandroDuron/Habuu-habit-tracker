import '../models/habit_log.dart';
import '../models/home_habit.dart';

abstract interface class HomeDataSource {
  /// Hábitos del usuario que no se han borrado, del más viejo al más nuevo.
  Future<List<HomeHabit>> getActiveHabits();

  /// Registros del usuario en un día.
  Future<List<HabitLog>> getLogsOn(DateTime day);

  /// Guarda cómo terminó un hábito en un día. Si ese día ya tenía registro,
  /// lo reemplaza, porque un hábito solo lleva un registro por día.
  Future<HabitLog> saveLog({
    required String habitId,
    required DateTime day,
    required LogStatus status,
    String? evidencePath,
  });
}

/// Error para cuando no hay nadie con sesión iniciada.
class NotSignedInException implements Exception {
  const NotSignedInException();

  @override
  String toString() => 'No hay una sesión iniciada';
}

/// Error al leer o guardar, con un mensaje listo para mostrarse.
class HomeDataException implements Exception {
  const HomeDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
