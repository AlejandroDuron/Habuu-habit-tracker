// Tests de widget para StreakScreen.
// Se verifica el loading, los casos con racha, sin racha, y la integración
// con TrophiesSummary. HomeProvider se necesita solo para frogAwake.
//
// NOTA: StreakHeader contiene AnimatedFrog con animaciones infinitas (breathe/hop),
// lo que impide usar pumpAndSettle(). Todos los tests usan pump(duration) para
// avanzar el tiempo sin esperar que el árbol se estabilice por completo.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/models/streak_data.dart';
import 'package:habuu/data/models/trophy.dart';
import 'package:habuu/data/repositories/home_repository.dart';
import 'package:habuu/data/repositories/streak_repository.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';
import 'package:habuu/presentation/providers/home_provider.dart';
import 'package:habuu/presentation/providers/streaks_provider.dart';
import 'package:habuu/presentation/providers/trophies_provider.dart';
import 'package:habuu/presentation/screens/streaks/streaks_screen.dart';
import 'package:habuu/presentation/widgets/streaks/calendar.dart';
import 'package:habuu/presentation/widgets/streaks/streak_header.dart';
import 'package:habuu/presentation/widgets/streaks/throphies_sumary.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../fakes/fake_daily_summary_data_source.dart';
import '../fakes/fake_evidence_data_source.dart';
import '../fakes/fake_home_data_source.dart';
import '../fakes/fake_photo_verifier.dart';
import '../fakes/fake_streak_data_source.dart';
import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(() async {
    // El Calendar embebido en StreakScreen usa locale es_ES
    await initializeDateFormatting('es_ES');
  });

  /// Duración que usamos en pump() para darle tiempo al postFrameCallback
  /// y a los futures del provider sin bloquear por animaciones infinitas.
  const settle = Duration(milliseconds: 300);

  /// Monta StreakScreen con los tres providers requeridos.
  Future<void> pumpScreen(
    WidgetTester tester, {
    StreakData? streakData,
    bool streakShouldFail = false,
    List<EarnedTrophy>? earned,
    bool trophiesShouldFail = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final streakDs = FakeStreakDataSource(
      data: streakData,
      shouldFail: streakShouldFail,
    );
    final trophyDs = FakeTrophyDataSourceFull(
      earnedTrophies: earned,
      shouldFail: trophiesShouldFail,
    );
    final trophiesProvider = TrophiesProvider(TrophyRepository(trophyDs));
    final streaksProvider = StreaksProvider(
      StreakRepository(streakDs),
      trophies: trophiesProvider,
    );
    final homeProvider = HomeProvider(
      HomeRepository(
        FakeHomeDataSource(),
        FakeEvidenceDataSource(),
        FakeDailySummaryDataSource(),
        verifier: FakePhotoVerifier(),
      ),
      trophies: trophiesProvider,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: streaksProvider),
          ChangeNotifierProvider.value(value: trophiesProvider),
          ChangeNotifierProvider.value(value: homeProvider),
        ],
        child: const MaterialApp(home: Scaffold(body: StreakScreen())),
      ),
    );
  }

  group('estado de carga', () {
    testWidgets('muestra CircularProgressIndicator mientras carga racha',
        (tester) async {
      // Usamos delay para que el future no resuelva en el mismo microtask
      // y podamos capturar el estado isLoading=true.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final streakDs = FakeStreakDataSource(
        data: const StreakData.empty(),
        delay: const Duration(milliseconds: 100),
      );
      final trophyDs = FakeTrophyDataSourceFull();
      final trophiesProvider = TrophiesProvider(TrophyRepository(trophyDs));
      final streaksProvider = StreaksProvider(
        StreakRepository(streakDs),
        trophies: trophiesProvider,
      );
      final homeProvider = HomeProvider(
        HomeRepository(
          FakeHomeDataSource(),
          FakeEvidenceDataSource(),
          FakeDailySummaryDataSource(),
          verifier: FakePhotoVerifier(),
        ),
        trophies: trophiesProvider,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: streaksProvider),
            ChangeNotifierProvider.value(value: trophiesProvider),
            ChangeNotifierProvider.value(value: homeProvider),
          ],
          child: const MaterialApp(home: Scaffold(body: StreakScreen())),
        ),
      );

      // pump() ejecuta el postFrameCallback → inicia loadStreak() con 100ms delay.
      // El estado pasa a loading pero el future aún no resolvió.
      await tester.pump();
      await tester.pump(); // segundo pump para reconstruir con isLoading=true

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Deja que el future resuelva para no dejar timers pendientes
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('el indicador desaparece al terminar la carga', (tester) async {
      await pumpScreen(tester);
      // Dejamos tiempo para que el future del fake resuelva y el provider
      // actualice el estado a "ready".
      await tester.pump();
      await tester.pump(settle);

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('racha cero', () {
    testWidgets('muestra StreakHeader, Calendar y TrophiesSummary',
        (tester) async {
      await pumpScreen(tester, streakData: const StreakData.empty());
      await tester.pump();
      await tester.pump(settle);

      expect(find.byType(StreakHeader), findsOneWidget);
      expect(find.byType(Calendar), findsOneWidget);
      expect(find.byType(TrophiesSummary), findsOneWidget);
    });

    testWidgets('muestra "0" y "Días de racha"', (tester) async {
      await pumpScreen(tester, streakData: const StreakData.empty());
      await tester.pump();
      await tester.pump(settle);

      expect(find.text('0'), findsOneWidget);
      expect(find.text('Días de racha'), findsOneWidget);
    });

    testWidgets('muestra mensaje de cero trofeos en TrophiesSummary',
        (tester) async {
      await pumpScreen(
        tester,
        streakData: const StreakData.empty(),
        earned: [],
      );
      await tester.pump();
      await tester.pump(settle);

      expect(find.text('Aún no has ganado trofeos'), findsOneWidget);
    });
  });

  group('racha activa', () {
    testWidgets('muestra el número de días correcto', (tester) async {
      await pumpScreen(
        tester,
        streakData: StreakData(
          currentStreak: 14,
          streakDays: {DateTime(2026, 10, 20)},
        ),
      );
      await tester.pump();
      await tester.pump(settle);

      // El número "14" aparece dos veces: en el header (56px) y en el calendario.
      // Verificamos que al menos hay uno, y que el texto "Días de racha" es único.
      expect(find.text('14'), findsAtLeastNWidgets(1));
      expect(find.text('Días de racha'), findsOneWidget);
    });

    testWidgets('muestra "1 Día de racha" con racha de 1', (tester) async {
      await pumpScreen(
        tester,
        streakData: StreakData(
          currentStreak: 1,
          streakDays: {DateTime(2026, 11, 2)},
        ),
      );
      await tester.pump();
      await tester.pump(settle);

      // "1" puede aparecer en el calendario también; buscamos al menos uno.
      expect(find.text('1'), findsAtLeastNWidgets(1));
      expect(find.text('Día de racha'), findsOneWidget);
    });
  });

  group('días de racha en el calendario', () {
    testWidgets('el Calendar recibe el Set de streakDays del provider',
        (tester) async {
      final days = {DateTime(2026, 11, 1), DateTime(2026, 11, 2)};
      await pumpScreen(
        tester,
        streakData: StreakData(currentStreak: 2, streakDays: days),
      );
      await tester.pump();
      await tester.pump(settle);

      final calendar = tester.widget<Calendar>(find.byType(Calendar));
      expect(calendar.streakDays, days);
    });

    testWidgets('TableCalendar está presente en la pantalla', (tester) async {
      await pumpScreen(tester, streakData: const StreakData.empty());
      await tester.pump();
      await tester.pump(settle);

      expect(find.byType(TableCalendar), findsOneWidget);
    });
  });

  group('trofeos en StreakScreen', () {
    testWidgets('TrophiesSummary muestra el trofeo más reciente', (tester) async {
      final earnedList = [
        EarnedTrophy(
          trophy: const Trophy(
            id: 'streak_7',
            name: 'Racha de 7 días',
            key: 'streak_7',
          ),
          earnedAt: DateTime(2026, 11, 1),
        ),
      ];
      await pumpScreen(
        tester,
        streakData: StreakData(currentStreak: 7, streakDays: {}),
        earned: earnedList,
      );
      await tester.pump();
      await tester.pump(settle);

      expect(find.text('Racha de 7 días'), findsOneWidget);
    });

    testWidgets('botón "Ver todos los trofeos" existe', (tester) async {
      await pumpScreen(tester);
      await tester.pump();
      await tester.pump(settle);

      expect(find.text('Ver todos los trofeos'), findsOneWidget);
    });
  });

  group('error de racha', () {
    testWidgets('en caso de error renderiza sin explotar',
        (tester) async {
      await pumpScreen(tester, streakShouldFail: true);
      await tester.pump();
      await tester.pump(settle);

      // La pantalla no debe lanzar excepción (muestra loading → error estado)
      expect(tester.takeException(), isNull);
    });
  });
}
