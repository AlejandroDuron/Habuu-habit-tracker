import '../../utils/dates.dart';
import '../datasources/habit_data_source.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

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

  /// Devuelve el estado del log de cada hábito en [day].
  /// Solo incluye hábitos que tienen un registro ese día.
  Future<Map<String, LogStatus>> getLogStatusesForDay(DateTime day) =>
      _dataSource.getLogStatusesForDay(day);

  Future<Map<String, Map<DateTime, LogStatus>>> getWeekLogStatuses(
    DateTime day,
  ) async {
    final start = weekStartOf(day);
    final end = start.add(const Duration(days: 6));
    final logs = await _dataSource.getLogsBetween(start, end);

    final byHabit = <String, Map<DateTime, LogStatus>>{};
    for (final log in logs) {
      if (log.logDate.isBefore(start) || log.logDate.isAfter(end)) continue;
      byHabit.putIfAbsent(log.habitId, () => {})[log.logDate] = log.status;
    }
    return byHabit;
  }
}
