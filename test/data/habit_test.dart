// Pruebas unitarias del modelo Habit. Aquí no hay pantallas porque solo revisamos que la clase se porte
// como esperamos con datos normales y con casos raros

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/habit.dart';

import '../fakes/fake_habit_data_source.dart';

void main() {
  group('Valores derivados (getters)', () {
    test('isFrequent depende del tipo', () {
      expect(buildHabit(type: HabitType.frecuente).isFrequent, isTrue);
      expect(buildHabit(type: HabitType.fugaz).isFrequent, isFalse);
    });

    test('goalLabel usa singular con 1 y plural con más', () {
      expect(buildHabit(goalPerDay: 1).goalLabel, '1 Vez o más al día');
      expect(buildHabit(goalPerDay: 3).goalLabel, '3 veces al día');
    });
  });

  group('Asserts del constructor', () {
    // Los assert solo corren en modo debug, que es como corren las pruebas
    test('no deja crear un hábito con nombre vacío', () {
      expect(() => buildHabit(name: '   '), throwsA(isA<AssertionError>()));
    });

    test('no deja una meta menor a 1', () {
      expect(() => buildHabit(goalPerDay: 0), throwsA(isA<AssertionError>()));
    });

    test('no deja días fuera del rango 1 a 31', () {
      expect(() => buildHabit(days: {0}), throwsA(isA<AssertionError>()));
      expect(() => buildHabit(days: {32}), throwsA(isA<AssertionError>()));
    });

    test('un hábito fugaz no puede tener repetición', () {
      expect(
        () => Habit(
          id: '1',
          name: 'Ir al banco',
          type: HabitType.fugaz,
          category: HabitCategory.hogar,
          iconIndex: 0,
          colorValue: 0xFFFFC654,
          reminderTime: null,
          goalPerDay: 1,
          createdAt: DateTime(2026, 11, 2),
          repeat: HabitRepeat.diariamente,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('copyWith', () {
    test('cambia solo lo que se le pasa', () {
      final original = buildHabit(id: 'a', name: 'Leer');
      final copy = original.copyWith(name: 'Leer 20 min');

      expect(copy.name, 'Leer 20 min');
      expect(copy.id, 'a');
      expect(copy.category, original.category);
      expect(copy.createdAt, original.createdAt);
    });

    test('clearRepeat borra la repetición aunque sea null a propósito', () {
      final habit = buildHabit(repeat: HabitRepeat.semanalmente, days: {1});
      final copy = habit.copyWith(type: HabitType.fugaz, clearRepeat: true);

      expect(copy.repeat, isNull);
      expect(copy.type, HabitType.fugaz);
    });

    test('clearReminderTime quita la hora del recordatorio', () {
      final habit = buildHabit().copyWith(reminderTime: (hour: 7, minute: 30));
      expect(habit.reminderTime, (hour: 7, minute: 30));

      final copy = habit.copyWith(clearReminderTime: true);
      expect(copy.reminderTime, isNull);
    });
  });

  group('toMap / fromMap', () {
    test('ida y vuelta conserva todos los datos', () {
      final habit = buildHabit(
        id: 'x1',
        name: 'Correr',
        repeat: HabitRepeat.semanalmente,
        days: {5, 1, 3},
        goalPerDay: 2,
      ).copyWith(reminderTime: (hour: 18, minute: 5));

      final back = Habit.fromMap(habit.toMap());

      expect(back.id, habit.id);
      expect(back.name, habit.name);
      expect(back.type, habit.type);
      expect(back.category, habit.category);
      expect(back.repeat, HabitRepeat.semanalmente);
      expect(back.days, {1, 3, 5});
      expect(back.reminderTime, (hour: 18, minute: 5));
      expect(back.goalPerDay, 2);
      expect(back.createdAt, habit.createdAt);
    });

    test('toMap guarda los enums por su nombre y los días ordenados', () {
      final map = buildHabit(
        repeat: HabitRepeat.semanalmente,
        days: {7, 2},
      ).toMap();

      expect(map['type'], 'frecuente');
      expect(map['category'], 'salud');
      expect(map['repeat'], 'semanalmente');
      expect(map['days'], [2, 7]);
    });

    test('fromMap usa valores por defecto si faltan campos opcionales', () {
      final habit = Habit.fromMap({
        'id': '9',
        'name': 'Meditar',
        'type': 'fugaz',
        'category': 'universidad',
        'iconIndex': 2,
        'colorValue': 0xFF3FB3CD,
        'goalPerDay': 1,
        'createdAt': '2026-11-02T10:00:00.000',
      });

      expect(habit.repeat, isNull);
      expect(habit.days, isEmpty);
      expect(habit.reminderTime, isNull);
      expect(habit.allowSkip, isFalse);
      expect(habit.remindersEnabled, isTrue);
    });
  });
}