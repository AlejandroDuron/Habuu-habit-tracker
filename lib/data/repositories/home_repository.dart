import '../../utils/habit_schedule.dart';
import '../datasources/home_data_source.dart';
import '../models/habit_log.dart';
import '../models/home_habit.dart';
import '../models/today_habit.dart';

class HomeRepository {
  // Depende del contrato, no de Supabase: así se puede usar el Fake.
  HomeRepository(this._dataSource);

  final HomeDataSource _dataSource;

  /// Hábitos que tocan en [day], cada uno con su registro de ese día.
  Future<List<TodayHabit>> getHabitsFor(DateTime day) async {
    // Las dos consultas no dependen una de la otra: van al mismo tiempo.
    // Future.wait deja pasar el error original si alguna falla.
    final results = await Future.wait([
      _dataSource.getActiveHabits(),
      _dataSource.getLogsOn(day),
    ]);
    final habits = results[0] as List<HomeHabit>;
    final logs = results[1] as List<HabitLog>;

    final logByHabit = {for (final log in logs) log.habitId: log};

    return [
      for (final habit in habits)
        if (isScheduledOn(habit, day))
          TodayHabit(habit: habit, log: logByHabit[habit.id]),
    ];
  }

  /// Marca un hábito como cumplido en [day], con o sin foto.
  Future<HabitLog> markDone(
    String habitId,
    DateTime day, {
    String? evidencePath,
  }) {
    return _dataSource.saveLog(
      habitId: habitId,
      day: day,
      status: LogStatus.done,
      evidencePath: evidencePath,
    );
  }

  /// Froggy despierta en cuanto se cumple al menos un hábito.
  /// Los omitidos no cuentan.
  static bool isFrogAwake(List<TodayHabit> habits) =>
      habits.any((h) => h.isDone);
}
