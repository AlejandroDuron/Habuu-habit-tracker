// Tests unitarios del StreakRepository.
// El repository es delgado (solo delega), pero probamos que propaga
// los datos y los errores correctamente.

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/streak_data.dart';
import 'package:habuu/data/repositories/streak_repository.dart';

import '../fakes/fake_streak_data_source.dart';

void main() {
  late FakeStreakDataSource dataSource;
  late StreakRepository repository;

  setUp(() {
    dataSource = FakeStreakDataSource();
    repository = StreakRepository(dataSource);
  });

  test('getStreak delega al dataSource y devuelve los datos', () async {
    final days = {DateTime(2026, 11, 1), DateTime(2026, 11, 2)};
    dataSource = FakeStreakDataSource(
      data: StreakData(currentStreak: 2, streakDays: days),
    );
    repository = StreakRepository(dataSource);

    final result = await repository.getStreak();

    expect(result.currentStreak, 2);
    expect(result.streakDays, days);
    expect(dataSource.getCalls, 1);
  });

  test('getStreak devuelve StreakData.empty() si la fuente lo devuelve', () async {
    final result = await repository.getStreak();

    expect(result.currentStreak, 0);
    expect(result.streakDays, isEmpty);
  });

  test('propaga la excepción si el dataSource falla', () async {
    dataSource.shouldFail = true;
    repository = StreakRepository(dataSource);

    expect(() => repository.getStreak(), throwsA(isA<Exception>()));
  });

  test('llama al dataSource solo una vez por invocación', () async {
    await repository.getStreak();
    await repository.getStreak();

    expect(dataSource.getCalls, 2);
  });
}
