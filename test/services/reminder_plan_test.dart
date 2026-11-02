// Pruebas unitarias del plan de recordatorios. Como planReminders recibe
// "now" por parámetro, podemos fingir cualquier fecha y hora sin esperar
// a que de verdad sean las 8:00

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/habit.dart';
import 'package:habuu/services/reminder_plan.dart';

import '../fakes/fake_habit_data_source.dart';

void main() {
  // Lunes 2 de noviembre de 2026, 10:00 de la mañana.
  final now = DateTime(2026, 11, 2, 10);

  /// Hábito con recordatorio a la hora indicada
  Habit withReminder(
    Habit habit, {
    int hour = 8,
    int minute = 0,
    bool enabled = true,
  }) {
    return habit.copyWith(
      id: 'habito-1',
      reminderTime: (hour: hour, minute: minute),
      remindersEnabled: enabled,
    );
  }

  group('Sin recordatorio', () {
    test('si están apagados no hay avisos', () {
      final habit = withReminder(buildHabit(), enabled: false);
      expect(planReminders(habit, now: now), isEmpty);
    });

    test('si no hay hora no hay avisos', () {
      final habit = buildHabit().copyWith(remindersEnabled: true);
      expect(planReminders(habit, now: now), isEmpty);
    });
  });

  group('Frecuente diario', () {
    test('si la hora ya pasó hoy, empieza mañana', () {
      final plan = planReminders(withReminder(buildHabit(), hour: 8), now: now);

      expect(plan.single.firstDate, DateTime(2026, 11, 3, 8));
      expect(plan.single.repeat, ReminderRepeat.daily);
    });

    test('si la hora todavía no llega, empieza hoy', () {
      final plan = planReminders(
        withReminder(buildHabit(), hour: 18, minute: 30),
        now: now,
      );

      expect(plan.single.firstDate, DateTime(2026, 11, 2, 18, 30));
    });
  });

  group('Frecuente semanal', () {
    test('un aviso por cada día elegido, en la próxima fecha', () {
      final habit = withReminder(
        buildHabit(repeat: HabitRepeat.semanalmente, days: {
          DateTime.friday,
          DateTime.monday,
        }),
        hour: 7,
      );

      final plan = planReminders(habit, now: now);

      expect(plan, hasLength(2));
      expect(plan[0].firstDate, DateTime(2026, 11, 9, 7));
      expect(plan[1].firstDate, DateTime(2026, 11, 6, 7));
      expect(plan.every((r) => r.repeat == ReminderRepeat.weekly), isTrue);
    });

    test('cada día tiene su propio id', () {
      final habit = withReminder(
        buildHabit(repeat: HabitRepeat.semanalmente, days: {1, 3, 5}),
      );

      final ids = planReminders(habit, now: now).map((r) => r.id).toSet();

      expect(ids, hasLength(3));
    });
  });

  group('Frecuente mensual', () {
    test('el día elegido de este mes si no ha pasado', () {
      final habit = withReminder(
        buildHabit(repeat: HabitRepeat.mensualmente, days: {15}),
      );

      final plan = planReminders(habit, now: now);

      expect(plan.single.firstDate, DateTime(2026, 11, 15, 8));
      expect(plan.single.repeat, ReminderRepeat.monthly);
    });

    test('se salta los meses que no tienen ese día', () {
      // Noviembre no tiene 31, el siguiente 31 es en diciembre.
      final habit = withReminder(
        buildHabit(repeat: HabitRepeat.mensualmente, days: {31}),
      );

      final plan = planReminders(habit, now: now);

      expect(plan.single.firstDate, DateTime(2026, 12, 31, 8));
    });
  });

  group('Fugaz', () {
    test('un solo aviso el día en que se creó', () {
      final habit = withReminder(
        buildHabit(type: HabitType.fugaz, createdAt: now),
        hour: 15,
      );

      final plan = planReminders(habit, now: now);

      expect(plan.single.firstDate, DateTime(2026, 11, 2, 15));
      expect(plan.single.repeat, ReminderRepeat.once);
    });

    test('si la hora ya pasó no se programa nada', () {
      final habit = withReminder(
        buildHabit(type: HabitType.fugaz, createdAt: now),
        hour: 9,
      );

      expect(planReminders(habit, now: now), isEmpty);
    });
  });

  group('reminderBaseId', () {
    test('da siempre el mismo número para el mismo hábito', () {
      expect(reminderBaseId('abc-123'), reminderBaseId('abc-123'));
    });

    test('hábitos distintos tienen ids distintos', () {
      expect(reminderBaseId('abc-123'), isNot(reminderBaseId('abc-124')));
    });

    test('cabe en un entero de 32 bits como pide Android', () {
      for (final id in ['a', 'otro-habito', 'f47ac10b-58cc-4372-a567']) {
        final last = reminderBaseId(id) + maxRemindersPerHabit - 1;
        expect(last, lessThan(0x7FFFFFFF));
        expect(reminderBaseId(id), greaterThanOrEqualTo(0));
      }
    });
  });
}