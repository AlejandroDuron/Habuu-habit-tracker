import '../datasources/habit_data_source.dart';
import '../models/habit.dart';
 
class HabitRepository {
  // El repository depende del contrato HabitDataSource
  HabitRepository(this._dataSource);
 
  final HabitDataSource _dataSource;
 
  /// Trae los hábitos ordenados del más nuevo al más viejo, para que el
  /// recién creado salga primero en "tus habitos"
  Future<List<Habit>> getHabits() async {
    final habits = await _dataSource.getHabits();
 
    // Hacemos una copia porque la lista que llega no se puede modificar,
    // y sort() ordena la lista
    return [...habits]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
 
  Future<Habit> createHabit(Habit habit) => _dataSource.createHabit(habit);
 
  Future<Habit> updateHabit(Habit habit) => _dataSource.updateHabit(habit);
 
  Future<void> deleteHabit(String id) => _dataSource.deleteHabit(id);
}