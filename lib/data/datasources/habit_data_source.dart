import '../models/habit.dart';
 
abstract interface class HabitDataSource {
  /// Devuelve todos los hábitos guardados
  Future<List<Habit>> getHabits();
 
  /// Guarda un hábito nuevo y lo devuelve ya con su id asignado
  Future<Habit> createHabit(Habit habit);
 
  /// Reemplaza un hábito que ya existe, buscandolo por su id
  Future<Habit> updateHabit(Habit habit);
 
  /// Borra un hábito por su id

  Future<void> deleteHabit(String id);
}
 
/// Error propio para cuando se busca un hábito que no existe
class HabitNotFoundException implements Exception {
  const HabitNotFoundException(this.id);
 
  final String id;
 
  @override
  String toString() => 'No se encontró el hábito con id "$id"';
}