import 'dart:ui';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../../data/models/home_habit.dart';
import '../../../data/models/today_habit.dart';
import '../../../utils/habit_style.dart';

/// Lo que necesita una HabitCard para dibujarse.
class HabitCardData {
  const HabitCardData({
    required this.habitId,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    this.color = defaultColor,
    this.isDone = false,
  });

  /// Arma la tarjeta de un hábito de hoy. Si el ícono o el color guardados
  /// no son válidos, usa los de por defecto en vez de fallar.
  factory HabitCardData.fromTodayHabit(TodayHabit today) {
    final habit = today.habit;
    return HabitCardData(
      habitId: habit.id,
      title: habit.name,
      subtitle: habit.goal ?? _scheduleLabel(habit),
      iconAsset: HabitIconAssets.forKey(habit.iconKey),
      color: colorFromHex(habit.color) ?? defaultColor,
      isDone: today.isDone,
    );
  }

  static const defaultColor = HabuuColors.success700;

  final String habitId;
  final String title;

  /// Texto debajo del título, por ejemplo la meta del hábito.
  final String subtitle;

  final String iconAsset;

  /// Color que eligió el usuario para el hábito.
  final Color color;

  /// Si ya se cumplió hoy.
  final bool isDone;

  /// Si el hábito no tiene meta escrita, se dice cada cuánto toca.
  static String _scheduleLabel(HomeHabit habit) {
    return switch ((habit.type, habit.frequency)) {
      (HomeHabitType.oneTime, _) => 'Solo por hoy',
      (_, HabitFrequency.weekly) => 'Cada semana',
      (_, HabitFrequency.monthly) => 'Cada mes',
      (_, null) => '',
    };
  }
}
