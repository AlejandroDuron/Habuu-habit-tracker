// Tests unitarios del modelo StreakData y su constructor vacío.

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/streak_data.dart';

void main() {
  group('StreakData', () {
    test('StreakData.empty() inicia racha en 0 y sin días', () {
      const data = StreakData.empty();

      expect(data.currentStreak, 0);
      expect(data.streakDays, isEmpty);
    });

    test('guarda la racha y los días correctamente', () {
      final days = {
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 3),
      };

      final data = StreakData(currentStreak: 3, streakDays: days);

      expect(data.currentStreak, 3);
      expect(data.streakDays, days);
    });

    test('racha de 1 día', () {
      final data = StreakData(
        currentStreak: 1,
        streakDays: {DateTime(2026, 11, 2)},
      );

      expect(data.currentStreak, 1);
      expect(data.streakDays, hasLength(1));
    });

    test('admite racha larga con muchos días', () {
      final days = List.generate(
        30,
        (i) => DateTime(2026, 10, 1).add(Duration(days: i)),
      ).toSet();

      final data = StreakData(currentStreak: 30, streakDays: days);

      expect(data.currentStreak, 30);
      expect(data.streakDays, hasLength(30));
    });
  });
}
