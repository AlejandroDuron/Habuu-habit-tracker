// El plan de recordatorios decide cuando debe sonar cada aviso de un hábito.
// Aquí no hay nada de Flutter ni del paquete de notificaciones, solo Dart
// puro, así lo podemos probar con pruebas unitarias normales y
// el servicio de notificaciones solo se encarga de mandar el plan al
// sistema operativo.

import '../data/models/habit.dart';

/// Cada cuánto se repite un aviso.
enum ReminderRepeat { once, daily, weekly, monthly }

/// Un aviso ya calculado, con su id, la primera vez que suena y cómo se repite
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.firstDate,
    required this.repeat,
  });

  /// Id numérico que pide el sistema operativo para poder cancelarlo luego
  final int id;

  /// Fecha y hora del primer aviso. Si es un hábito frecuente, se repite
  final DateTime firstDate;
  final ReminderRepeat repeat;

  @override
  String toString() => 'PlannedReminder($id, $firstDate, ${repeat.name})';
}

const maxRemindersPerHabit = 10;

int reminderBaseId(String habitId) {
  var hash = 0x811c9dc5;
  for (final unit in habitId.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return (hash % 200000000) * maxRemindersPerHabit;
}

List<PlannedReminder> planReminders(Habit habit, {required DateTime now}) {
  final time = habit.reminderTime;
  if (!habit.remindersEnabled || time == null) return const [];

  final base = reminderBaseId(habit.id);

  // Fecha con la hora del recordatorio, sin segundos
  DateTime at(DateTime day) =>
      DateTime(day.year, day.month, day.day, time.hour, time.minute);

  if (habit.type == HabitType.fugaz) {
    final date = at(habit.createdAt);
    if (!date.isAfter(now)) return const [];
    return [
      PlannedReminder(id: base, firstDate: date, repeat: ReminderRepeat.once),
    ];
  }

  switch (habit.repeat) {
    case null:
      // Un frecuente sin repetición es un dato incompleto, no debería pasar nunca. Pero si pasa, no programamos nada
      return const [];

    case HabitRepeat.diariamente:
      var date = at(now);
      if (!date.isAfter(now)) date = at(now.add(const Duration(days: 1)));
      return [
        PlannedReminder(id: base, firstDate: date, repeat: ReminderRepeat.daily),
      ];

    case HabitRepeat.semanalmente:
      // Ordenamos los días para que los ids salgan siempre en el mismo orden
      final weekdays = habit.days.where((d) => d >= 1 && d <= 7).toList()
        ..sort();
      return [
        for (var i = 0; i < weekdays.length; i++)
          PlannedReminder(
            id: base + i,
            firstDate: _nextWeekday(weekdays[i], now, at),
            repeat: ReminderRepeat.weekly,
          ),
      ];

    case HabitRepeat.mensualmente:
      if (habit.days.isEmpty) return const [];
      final day = habit.days.first;
      final date = _nextMonthDay(day, now, at);
      if (date == null) return const [];
      return [
        PlannedReminder(
          id: base,
          firstDate: date,
          repeat: ReminderRepeat.monthly,
        ),
      ];
  }
}


DateTime _nextWeekday(
  int weekday,
  DateTime now,
  DateTime Function(DateTime) at,
) {
  for (var i = 0; i <= 7; i++) {
    final candidate = at(now.add(Duration(days: i)));
    if (candidate.weekday == weekday && candidate.isAfter(now)) {
      return candidate;
    }
  }

  throw StateError('Día de la semana inválido: $weekday');
}

DateTime? _nextMonthDay(
  int day,
  DateTime now,
  DateTime Function(DateTime) at,
) {
  for (var i = 0; i < 12; i++) {
    final month = DateTime(now.year, now.month + i, 1);
    final candidate = DateTime(month.year, month.month, day);
    // Si el mes no tiene ese día, DateTime se pasa al mes siguiente.
    if (candidate.month != month.month) continue;
    final date = at(candidate);
    if (date.isAfter(now)) return date;
  }
  return null;
}