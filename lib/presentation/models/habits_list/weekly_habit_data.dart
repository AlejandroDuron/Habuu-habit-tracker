import 'package:flutter/painting.dart';

import '../../../data/models/habit.dart';
import '../../../data/models/habit_log.dart';
import '../../../utils/dates.dart';

enum WeekDayState { done, skipped, empty }

class WeeklyHabitData {
  WeeklyHabitData({
    required this.title,
    required this.frequencyLabel,
    required this.iconIndex,
    required this.color,
    required this.days,
  }) : assert(days.length == 7, 'Una semana tiene 7 días');

  factory WeeklyHabitData.fromHabit(
    Habit habit,
    Map<DateTime, LogStatus> statuses, {
    required DateTime weekStart,
  }) {
    final start = dateOnly(weekStart);
    return WeeklyHabitData(
      title: habit.name,
      frequencyLabel: frequencyLabelFor(habit),
      iconIndex: habit.iconIndex,
      color: Color(habit.colorValue),
      days: [
        for (var i = 0; i < 7; i++)
          switch (statuses[start.add(Duration(days: i))]) {
            LogStatus.done => WeekDayState.done,
            LogStatus.skipped => WeekDayState.skipped,
            null => WeekDayState.empty,
          },
      ],
    );
  }

  final String title;
  final String frequencyLabel;
  final int iconIndex;
  final Color color;
  final List<WeekDayState> days;
}

String frequencyLabelFor(Habit habit) {
  if (habit.type == HabitType.fugaz) return 'Una vez';
  return switch (habit.repeat) {
    HabitRepeat.diariamente => 'Diario',
    HabitRepeat.semanalmente when habit.days.isNotEmpty =>
      '${habit.days.length}x semana',
    HabitRepeat.semanalmente => 'Semanal',
    HabitRepeat.mensualmente => 'Mensual',
    null => 'Sin repetición',
  };
}
