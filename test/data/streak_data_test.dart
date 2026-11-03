import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/streak_data.dart';

void main() {
  group('StreakData', () {
    test('empty() arranca en cero sin días', () {
      const data = StreakData.empty();
      expect(data.currentStreak, 0);
      expect(data.streakDays, isEmpty);
    });

    test('guarda racha y días correctamente', () {
      final days = {DateTime(2026, 11, 1), DateTime(2026, 11, 2)};
      final data = StreakData(currentStreak: 2, streakDays: days);
      expect(data.currentStreak, 2);
      expect(data.streakDays, days);
    });
  });
}
