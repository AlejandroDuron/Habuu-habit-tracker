import 'dart:math' as math;

import '../data/models/home_habit.dart';
import 'dates.dart';

/// Dice si a un hábito le toca aparecer en [day].
///
/// - Semanal: si el día de la semana está entre los elegidos.
/// - Mensual: si es el día elegido. Si el mes es más corto (un 31 en
///   abril), toca el último día del mes.
/// - De un solo día: solo el día en que se creó.
bool isScheduledOn(HomeHabit habit, DateTime day) {
  final date = dateOnly(day);

  // Antes de crearse, el hábito no existe.
  if (date.isBefore(habit.createdDate)) return false;

  return switch (habit.type) {
    HomeHabitType.oneTime => date == habit.createdDate,
    HomeHabitType.recurring => switch (habit.frequency) {
      HabitFrequency.weekly => habit.daysOfWeek.contains(date.weekday),
      HabitFrequency.monthly => _isMonthlyDay(habit.dayOfMonth, date),
      // Un recurrente sin frecuencia es un dato incompleto: no se muestra.
      null => false,
    },
  };
}

bool _isMonthlyDay(int? dayOfMonth, DateTime date) {
  if (dayOfMonth == null) return false;
  final lastDay = daysInMonth(date.year, date.month);
  return date.day == math.min(dayOfMonth, lastDay);
}
