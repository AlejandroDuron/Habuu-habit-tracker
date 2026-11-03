// Tests unitarios del StreaksProvider.
// Se verifica el ciclo loading→ready/error, los getters derivados
// y la integración opcional con TrophiesProvider.

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/streak_data.dart';
import 'package:habuu/data/repositories/streak_repository.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';
import 'package:habuu/presentation/providers/streaks_provider.dart';
import 'package:habuu/presentation/providers/trophies_provider.dart';

import '../fakes/fake_streak_data_source.dart';
import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  late FakeStreakDataSource streakDs;
  late StreaksProvider provider;
  late int notifications;

  void createProvider({
    StreakData? data,
    bool shouldFail = false,
    TrophiesProvider? trophies,
  }) {
    streakDs = FakeStreakDataSource(data: data, shouldFail: shouldFail);
    provider = StreaksProvider(
      StreakRepository(streakDs),
      trophies: trophies,
    );
    notifications = 0;
    provider.addListener(() => notifications++);
  }

  setUp(createProvider);

  group('estado inicial', () {
    test('comienza en StreaksStatus.initial con racha 0', () {
      expect(provider.status, StreaksStatus.initial);
      expect(provider.currentStreak, 0);
      expect(provider.streakDays, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });

  group('loadStreak — éxito', () {
    test('pasa a loading y luego a ready', () async {
      createProvider(
        data: StreakData(
          currentStreak: 5,
          streakDays: {DateTime(2026, 10, 29)},
        ),
      );

      final future = provider.loadStreak();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.status, StreaksStatus.ready);
      expect(provider.isLoading, isFalse);
    });

    test('expone currentStreak y streakDays correctamente', () async {
      final days = {DateTime(2026, 11, 1), DateTime(2026, 11, 2)};
      createProvider(data: StreakData(currentStreak: 2, streakDays: days));

      await provider.loadStreak();

      expect(provider.currentStreak, 2);
      expect(provider.streakDays, days);
    });

    test('notifica a los listeners durante la carga y al terminar', () async {
      await provider.loadStreak();

      // Al menos 2 notificaciones: una al empezar (loading) y una al terminar.
      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('clearsa el errorMessage al volver a cargar con éxito', () async {
      createProvider(shouldFail: true);
      await provider.loadStreak();
      expect(provider.errorMessage, isNotNull);

      // Segunda carga: esta vez sin error
      streakDs.shouldFail = false;
      await provider.loadStreak();

      expect(provider.errorMessage, isNull);
      expect(provider.status, StreaksStatus.ready);
    });
  });

  group('loadStreak — error', () {
    test('pasa a StreaksStatus.error y guarda el mensaje', () async {
      createProvider(shouldFail: true);

      await provider.loadStreak();

      expect(provider.status, StreaksStatus.error);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, 'No se pudo calcular tu racha');
    });

    test('mantiene los datos vacíos si nunca cargó bien', () async {
      createProvider(shouldFail: true);

      await provider.loadStreak();

      expect(provider.currentStreak, 0);
      expect(provider.streakDays, isEmpty);
    });
  });

  group('doble llamada mientras carga', () {
    test('no llama al dataSource dos veces si ya está loading', () async {
      createProvider(
        data: StreakData(currentStreak: 3, streakDays: {}),
      );
      // Lanzamos dos cargas simultáneas
      final f1 = provider.loadStreak();
      final f2 = provider.loadStreak();
      await Future.wait([f1, f2]);

      // Solo una llamada al datasource
      expect(streakDs.getCalls, 1);
    });
  });

  group('integración con TrophiesProvider', () {
    test('evalúa trofeos de racha después de cargar', () async {
      final trophyDs = FakeTrophyDataSourceFull(
        awardedTrophy: buildEarnedTrophy(
          trophy: buildTrophy(id: 'streak_7'),
        ),
      );
      final trophiesProvider = TrophiesProvider(TrophyRepository(trophyDs));

      createProvider(
        data: StreakData(currentStreak: 7, streakDays: {}),
        trophies: trophiesProvider,
      );

      await provider.loadStreak();

      // Con racha de 7, debe llamar al menos a streak_7
      expect(trophyDs.awardCalls, contains('streak_7'));
    });

    test('no explota si no hay TrophiesProvider', () async {
      createProvider(data: StreakData(currentStreak: 10, streakDays: {}));

      // No lanza excepción
      await expectLater(provider.loadStreak(), completes);
    });
  });
}
