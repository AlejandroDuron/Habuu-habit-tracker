import 'habit_log.dart';
import 'home_habit.dart';

/// Un hábito que toca hoy, junto con su registro si ya tiene uno.
class TodayHabit {
  const TodayHabit({required this.habit, this.log});

  final HomeHabit habit;
  final HabitLog? log;

  bool get isDone => log?.isDone ?? false;
}
