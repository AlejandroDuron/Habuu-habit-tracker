import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/streak_data.dart';
import 'package:habuu/data/repositories/streak_repository.dart';

import '../fakes/fake_streak_data_source.dart';

void main() {
  test('getStreak devuelve los datos del datasource', () async {
    final days = {DateTime(2026, 11, 1), DateTime(2026, 11, 2)};
    final repo = StreakRepository(
      FakeStreakDataSource(data: StreakData(currentStreak: 2, streakDays: days)),
    );
    final result = await repo.getStreak();
    expect(result.currentStreak, 2);
    expect(result.streakDays, days);
  });

  test('propaga la excepción si el datasource falla', () async {
    final repo = StreakRepository(FakeStreakDataSource(shouldFail: true));
    expect(() => repo.getStreak(), throwsA(isA<Exception>()));
  });
}
