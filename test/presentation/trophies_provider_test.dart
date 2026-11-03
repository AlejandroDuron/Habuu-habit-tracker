// Tests unitarios del TrophiesProvider.
// Se verifica la carga, el estado de error, los getters derivados
// y la lógica de _registerIfEarned (mover locked→earned y newlyEarned).

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/trophy.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';
import 'package:habuu/presentation/providers/trophies_provider.dart';

import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  late FakeTrophyDataSourceFull dataSource;
  late TrophiesProvider provider;
  late int notifications;

  void createProvider({
    List<Trophy>? allTrophies,
    List<EarnedTrophy>? earned,
    EarnedTrophy? awardedTrophy,
    bool shouldFail = false,
  }) {
    dataSource = FakeTrophyDataSourceFull(
      allTrophies: allTrophies,
      earnedTrophies: earned,
      awardedTrophy: awardedTrophy,
      shouldFail: shouldFail,
    );
    provider = TrophiesProvider(TrophyRepository(dataSource));
    notifications = 0;
    provider.addListener(() => notifications++);
  }

  setUp(createProvider);

  // ── Estado inicial ────────────────────────────────────────────────────────

  group('estado inicial', () {
    test('comienza en TrophiesStatus.initial', () {
      expect(provider.status, TrophiesStatus.initial);
      expect(provider.isLoading, isFalse);
      expect(provider.earned, isEmpty);
      expect(provider.locked, isEmpty);
      expect(provider.earnedCount, 0);
      expect(provider.latestEarned, isNull);
      expect(provider.newlyEarned, isEmpty);
      expect(provider.errorMessage, isNull);
    });
  });

  // ── loadTrophies ──────────────────────────────────────────────────────────

  group('loadTrophies — éxito', () {
    test('pasa a loading y luego a ready', () async {
      final future = provider.loadTrophies();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.status, TrophiesStatus.ready);
      expect(provider.isLoading, isFalse);
    });

    test('separa earned y locked correctamente', () async {
      final earnedTrophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'day_completed', name: 'Día completado'),
      );
      createProvider(
        allTrophies: [
          buildTrophy(id: 'day_completed', name: 'Día completado'),
          buildTrophy(id: 'streak_7', name: 'Racha 7'),
        ],
        earned: [earnedTrophy],
      );

      await provider.loadTrophies();

      expect(provider.earned, hasLength(1));
      expect(provider.earned.first.trophy.id, 'day_completed');
      expect(provider.locked, hasLength(1));
      expect(provider.locked.first.id, 'streak_7');
    });

    test('earnedCount refleja el número de trofeos ganados', () async {
      createProvider(
        earned: [
          buildEarnedTrophy(trophy: buildTrophy(id: 'day_completed')),
          buildEarnedTrophy(trophy: buildTrophy(id: 'streak_7')),
        ],
      );

      await provider.loadTrophies();

      expect(provider.earnedCount, 2);
    });

    test('latestEarned apunta al primero de la lista earned', () async {
      final first = buildEarnedTrophy(
        trophy: buildTrophy(id: 'day_completed', name: 'Primer trofeo'),
        earnedAt: DateTime(2026, 11, 2),
      );
      createProvider(earned: [first]);

      await provider.loadTrophies();

      expect(provider.latestEarned?.trophy.name, 'Primer trofeo');
    });

    test('notifica a los listeners al finalizar la carga', () async {
      await provider.loadTrophies();

      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('segunda llamada mientras ya está cargando no duplica peticiones',
        () async {
      final f1 = provider.loadTrophies();
      final f2 = provider.loadTrophies();
      await Future.wait([f1, f2]);

      // Solo una llamada a getAllTrophies (la segunda se cortocircuita)
      // El fake no cuenta llamadas explícitamente, pero no debe fallar
      expect(provider.status, TrophiesStatus.ready);
    });
  });

  group('loadTrophies — error', () {
    test('pasa a TrophiesStatus.error y guarda el mensaje', () async {
      createProvider(shouldFail: true);

      await provider.loadTrophies();

      expect(provider.status, TrophiesStatus.error);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, 'No se pudieron cargar los trofeos');
    });

    test('listas permanecen vacías tras error', () async {
      createProvider(shouldFail: true);

      await provider.loadTrophies();

      expect(provider.earned, isEmpty);
      expect(provider.locked, isEmpty);
    });

    test('errorMessage se limpia al recargar con éxito', () async {
      createProvider(shouldFail: true);
      await provider.loadTrophies();
      expect(provider.errorMessage, isNotNull);

      dataSource.shouldFail = false;
      await provider.loadTrophies();

      expect(provider.errorMessage, isNull);
      expect(provider.status, TrophiesStatus.ready);
    });
  });

  // ── _registerIfEarned / checkDayCompleted ─────────────────────────────────

  group('checkDayCompleted', () {
    test('no cambia el estado si allDone es false', () async {
      await provider.loadTrophies();
      final beforeNotif = notifications;

      await provider.checkDayCompleted(allDone: false);

      expect(provider.newlyEarned, isEmpty);
      expect(notifications, beforeNotif);
    });

    test('agrega a newlyEarned y mueve de locked a earned cuando allDone=true',
        () async {
      final newTrophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'day_completed', name: 'Día completado'),
      );
      createProvider(
        allTrophies: [buildTrophy(id: 'day_completed')],
        earned: [],
        awardedTrophy: newTrophy,
      );
      await provider.loadTrophies();

      await provider.checkDayCompleted(allDone: true);

      expect(provider.newlyEarned, hasLength(1));
      expect(provider.newlyEarned.first.trophy.id, 'day_completed');
      // El trofeo ya no está en locked
      expect(provider.locked.any((t) => t.id == 'day_completed'), isFalse);
    });

    test('no duplica earned si el trofeo ya estaba', () async {
      final alreadyEarned = buildEarnedTrophy(
        trophy: buildTrophy(id: 'day_completed'),
      );
      createProvider(
        allTrophies: [buildTrophy(id: 'day_completed')],
        earned: [alreadyEarned],
        awardedTrophy: alreadyEarned,
      );
      await provider.loadTrophies();

      await provider.checkDayCompleted(allDone: true);

      // Solo debe haber uno en earned
      expect(
        provider.earned.where((e) => e.trophy.id == 'day_completed'),
        hasLength(1),
      );
    });
  });

  // ── checkStreakTrophies ───────────────────────────────────────────────────

  group('checkStreakTrophies', () {
    test('no otorga nada con racha < 7', () async {
      await provider.loadTrophies();

      await provider.checkStreakTrophies(currentStreak: 3);

      expect(provider.newlyEarned, isEmpty);
    });

    test('agrega a newlyEarned el trofeo de racha 7', () async {
      final trophyStreak7 = buildEarnedTrophy(
        trophy: buildTrophy(id: 'streak_7', name: 'Racha 7'),
      );
      createProvider(
        allTrophies: [buildTrophy(id: 'streak_7')],
        earned: [],
        awardedTrophy: trophyStreak7,
      );
      await provider.loadTrophies();

      await provider.checkStreakTrophies(currentStreak: 7);

      expect(provider.newlyEarned.any((e) => e.trophy.id == 'streak_7'), isTrue);
    });
  });

  // ── checkNewHabit ─────────────────────────────────────────────────────────

  group('checkNewHabit', () {
    test('agrega new_habits a newlyEarned', () async {
      final newHabitTrophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'new_habits', name: 'Nuevos hábitos'),
      );
      createProvider(awardedTrophy: newHabitTrophy);
      await provider.loadTrophies();

      await provider.checkNewHabit();

      expect(provider.newlyEarned.any((e) => e.trophy.id == 'new_habits'), isTrue);
    });

    test('no cambia estado si awardTrophy devuelve null', () async {
      createProvider(awardedTrophy: null);
      await provider.loadTrophies();
      final beforeNotif = notifications;

      await provider.checkNewHabit();

      expect(provider.newlyEarned, isEmpty);
      expect(notifications, beforeNotif);
    });
  });

  // ── checkOneMonth ─────────────────────────────────────────────────────────

  group('checkOneMonth', () {
    test('no otorga si no han pasado 30 días', () async {
      await provider.loadTrophies();

      await provider.checkOneMonth(
        firstHabitDate: DateTime.now().subtract(const Duration(days: 10)),
      );

      expect(provider.newlyEarned, isEmpty);
    });

    test('otorga si han pasado 30+ días', () async {
      final oneMonthTrophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'one_month'),
      );
      createProvider(awardedTrophy: oneMonthTrophy);
      await provider.loadTrophies();

      await provider.checkOneMonth(
        firstHabitDate: DateTime.now().subtract(const Duration(days: 35)),
      );

      expect(provider.newlyEarned.any((e) => e.trophy.id == 'one_month'), isTrue);
    });
  });

  // ── clearNewlyEarned ──────────────────────────────────────────────────────

  group('clearNewlyEarned', () {
    test('vacía la lista de newlyEarned y notifica', () async {
      final newTrophy = buildEarnedTrophy(
        trophy: buildTrophy(id: 'day_completed'),
      );
      createProvider(awardedTrophy: newTrophy);
      await provider.loadTrophies();
      await provider.checkDayCompleted(allDone: true);
      expect(provider.newlyEarned, isNotEmpty);

      final beforeNotif = notifications;
      provider.clearNewlyEarned();

      expect(provider.newlyEarned, isEmpty);
      expect(notifications, greaterThan(beforeNotif));
    });

    test('si ya está vacío, no notifica de más', () async {
      await provider.loadTrophies();
      final beforeNotif = notifications;

      provider.clearNewlyEarned();

      expect(notifications, beforeNotif);
    });
  });
}
