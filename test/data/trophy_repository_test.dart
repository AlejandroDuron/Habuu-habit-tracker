// Tests unitarios del TrophyRepository.
// Se prueba la lógica de separar earned/locked, y cada regla de negocio
// de awarding trofeos, sin tocar Supabase gracias al fake.

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/trophy.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';

import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  late FakeTrophyDataSourceFull dataSource;
  late TrophyRepository repository;

  setUp(() {
    dataSource = FakeTrophyDataSourceFull();
    repository = TrophyRepository(dataSource);
  });

  group('getTrophies', () {
    test('devuelve todos los earned y los no-ganados en locked', () async {
      final earned = buildEarnedTrophy(
        trophy: buildTrophy(id: 'day_completed', name: 'Día completado'),
        earnedAt: DateTime(2026, 11, 1),
      );
      dataSource = FakeTrophyDataSourceFull(
        allTrophies: [
          buildTrophy(id: 'day_completed', name: 'Día completado'),
          buildTrophy(id: 'streak_7', name: 'Racha 7'),
        ],
        earnedTrophies: [earned],
      );
      repository = TrophyRepository(dataSource);

      final result = await repository.getTrophies();

      expect(result.earned, hasLength(1));
      expect(result.earned.first.trophy.id, 'day_completed');
      expect(result.locked, hasLength(1));
      expect(result.locked.first.id, 'streak_7');
    });

    test('si no tiene ninguno ganado, todos están en locked', () async {
      final result = await repository.getTrophies();

      expect(result.earned, isEmpty);
      expect(result.locked, hasLength(7)); // 7 trofeos por defecto en FakeTrophyDataSourceFull
    });

    test('si ganó todos, locked está vacío', () async {
      final all = _catalogoCompleto();
      final allEarned = all
          .map((t) => EarnedTrophy(trophy: t, earnedAt: DateTime(2026, 11, 1)))
          .toList();
      dataSource = FakeTrophyDataSourceFull(
        allTrophies: all,
        earnedTrophies: allEarned,
      );
      repository = TrophyRepository(dataSource);

      final result = await repository.getTrophies();

      expect(result.locked, isEmpty);
      expect(result.earned, hasLength(7));
    });
  });

  group('checkDayCompleted', () {
    test('no otorga trofeo si allDone es false', () async {
      final result = await repository.checkDayCompleted(allDone: false);

      expect(result, isNull);
      expect(dataSource.awardCalls, isEmpty);
    });

    test('otorga day_completed cuando allDone es true', () async {
      final trophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'day_completed'),
      );
      dataSource.awardedTrophy = trophy;

      final result = await repository.checkDayCompleted(allDone: true);

      expect(result, isNotNull);
      expect(dataSource.awardCalls, contains('day_completed'));
    });

    test('devuelve null si awardTrophy devuelve null (ya tenía el trofeo)',
        () async {
      dataSource.awardedTrophy = null;

      final result = await repository.checkDayCompleted(allDone: true);

      expect(result, isNull);
    });
  });

  group('checkStreakTrophies', () {
    test('no otorga nada con racha menor a 7', () async {
      final result = await repository.checkStreakTrophies(currentStreak: 5);

      expect(result, isEmpty);
      expect(dataSource.awardCalls, isEmpty);
    });

    test('otorga streak_7 con racha de exactamente 7', () async {
      final trophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'streak_7'),
      );
      dataSource.awardedTrophy = trophy;

      final result = await repository.checkStreakTrophies(currentStreak: 7);

      expect(dataSource.awardCalls, contains('streak_7'));
      expect(dataSource.awardCalls, isNot(contains('streak_14')));
      expect(result, hasLength(1));
    });

    test('otorga streak_7 y streak_14 con racha de 14', () async {
      // Ambas llamadas devolverán el mismo objeto; lo importante es que
      // se llame a los dos trophyKeys.
      dataSource.awardedTrophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'streak_14'),
      );

      final result = await repository.checkStreakTrophies(currentStreak: 14);

      expect(dataSource.awardCalls, containsAll(['streak_7', 'streak_14']));
      // 2 llamadas directas (sin streak_300 porque no hay _dailySummary)
      expect(dataSource.awardCalls.length, 2);
      expect(result, hasLength(2));
    });

    test('sin _dailySummary no evalúa streak_300', () async {
      // repository sin dailySummary (así fue creado en setUp)
      final result = await repository.checkStreakTrophies(currentStreak: 7);

      expect(dataSource.awardCalls, isNot(contains('streak_300')));
      // streak_300 nunca se llama
      expect(result.any((e) => e.trophy.id == 'streak_300'), isFalse);
    });
  });

  group('checkNewHabit', () {
    test('llama a awardTrophy con new_habits', () async {
      final trophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'new_habits'),
      );
      dataSource.awardedTrophy = trophy;

      final result = await repository.checkNewHabit();

      expect(dataSource.awardCalls, contains('new_habits'));
      expect(result, isNotNull);
    });

    test('devuelve null si ya tenía el trofeo', () async {
      dataSource.awardedTrophy = null;

      final result = await repository.checkNewHabit();

      expect(result, isNull);
    });
  });

  group('checkOneMonth', () {
    test('no otorga si no han pasado 30 días', () async {
      final firstHabit = DateTime.now().subtract(const Duration(days: 10));

      final result = await repository.checkOneMonth(firstHabitDate: firstHabit);

      expect(result, isNull);
      expect(dataSource.awardCalls, isEmpty);
    });

    test('otorga one_month si han pasado 30 o más días', () async {
      final firstHabit = DateTime.now().subtract(const Duration(days: 35));
      final trophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'one_month'),
      );
      dataSource.awardedTrophy = trophy;

      final result = await repository.checkOneMonth(firstHabitDate: firstHabit);

      expect(dataSource.awardCalls, contains('one_month'));
      expect(result, isNotNull);
    });

    test('exactamente 30 días: sí otorga', () async {
      final firstHabit = DateTime.now().subtract(const Duration(days: 30));
      dataSource.awardedTrophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'one_month'),
      );

      final result = await repository.checkOneMonth(firstHabitDate: firstHabit);

      expect(result, isNotNull);
    });
  });

  group('checkStreak300', () {
    test('sin _dailySummary siempre devuelve null', () async {
      final result = await repository.checkStreak300();

      expect(result, isNull);
      expect(dataSource.awardCalls, isEmpty);
    });
  });
}

/// Catálogo completo usado en tests (coincide con el de FakeTrophyDataSourceFull).
List<Trophy> _catalogoCompleto() => [
      const Trophy(id: 'day_completed', name: 'Día completado', key: 'day_completed'),
      const Trophy(id: 'streak_7', name: 'Racha de 7 días', key: 'streak_7'),
      const Trophy(id: 'new_habits', name: 'Nuevos hábitos', key: 'new_habits'),
      const Trophy(id: 'streak_14', name: 'Racha de 14 días', key: 'streak_14'),
      const Trophy(id: 'discipline', name: 'Disciplina', key: 'discipline'),
      const Trophy(id: 'one_month', name: 'Un mes con Habuu', key: 'one_month'),
      const Trophy(id: 'streak_300', name: '300 días', key: 'streak_300'),
    ];
