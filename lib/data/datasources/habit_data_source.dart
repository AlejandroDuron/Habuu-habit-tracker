import '../models/habit.dart';
import '../models/habit_log.dart';

abstract interface class HabitDataSource {
  /// Devuelve todos los hábitos guardados
  Future<List<Habit>> getHabits();

  /// Guarda un hábito nuevo y lo devuelve ya con su id asignado
  Future<Habit> createHabit(Habit habit);

  /// Reemplaza un hábito que ya existe, buscandolo por su id
  Future<Habit> updateHabit(Habit habit);

  /// Borra un hábito por su id

  Future<void> deleteHabit(String id);

  /// Devuelve un mapa de habit_id → LogStatus para los registros de [day].
  /// Solo incluye hábitos que tienen un log ese día.
  Future<Map<String, LogStatus>> getLogStatusesForDay(DateTime day);
}

/// Error propio para cuando se busca un hábito que no existe
class HabitNotFoundException implements Exception {
  const HabitNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'No se encontró el hábito con id "$id"';
}
