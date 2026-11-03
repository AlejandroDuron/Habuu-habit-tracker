// Tests de widget para TrophiesSummary.
// Se verifica el título, el TrophyCard cuando hay trofeos, el mensaje
// cuando no hay, y el botón de navegación a TrophiesScreen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';
import 'package:habuu/presentation/providers/trophies_provider.dart';
import 'package:habuu/presentation/widgets/streaks/throphies_sumary.dart';
import 'package:habuu/presentation/widgets/thophies/trophy_card.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(() async {
    // TrophiesScreen (destino del botón) no usa Calendar, pero inicializamos
    // por si algún widget del árbol lo requiere.
    await initializeDateFormatting('es_ES');
  });

  /// Monta TrophiesSummary dentro de un MaterialApp con Navigator y
  /// con TrophiesProvider, necesario para la navegación al pulsar el botón.
  Future<void> pumpSummary(
    WidgetTester tester, {
    int trophiesCount = 0,
    String latestTrophyImage =
        'assets/images/calendar/day_completed.png',
    String latestTrophyLabel = '',
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // TrophiesProvider es necesario porque el botón navega a TrophiesScreen.
    final trophiesProvider = TrophiesProvider(
      TrophyRepository(FakeTrophyDataSourceFull()),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: trophiesProvider,
        child: MaterialApp(
          home: Scaffold(
            body: TrophiesSummary(
              trophiesCount: trophiesCount,
              latestTrophyImage: latestTrophyImage,
              latestTrophyLabel: latestTrophyLabel,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('título de sección', () {
    testWidgets('siempre muestra "Trofeos Ganados"', (tester) async {
      await pumpSummary(tester);

      expect(find.text('Trofeos Ganados'), findsOneWidget);
    });
  });

  group('sin trofeos', () {
    testWidgets('muestra el mensaje de cero trofeos', (tester) async {
      await pumpSummary(tester, trophiesCount: 0);

      expect(find.text('Aún no has ganado trofeos'), findsOneWidget);
    });

    testWidgets('NO muestra TrophyCard cuando no hay trofeos', (tester) async {
      await pumpSummary(tester, trophiesCount: 0);

      expect(find.byType(TrophyCard), findsNothing);
    });
  });

  group('con trofeos', () {
    testWidgets('muestra TrophyCard con el label del último trofeo',
        (tester) async {
      await pumpSummary(
        tester,
        trophiesCount: 3,
        latestTrophyLabel: 'Racha de 7 días',
      );

      expect(find.byType(TrophyCard), findsOneWidget);
      expect(find.text('Racha de 7 días'), findsOneWidget);
    });

    testWidgets('NO muestra el mensaje de cero trofeos cuando hay trofeos',
        (tester) async {
      await pumpSummary(
        tester,
        trophiesCount: 1,
        latestTrophyLabel: 'Día completado',
      );

      expect(find.text('Aún no has ganado trofeos'), findsNothing);
    });

    testWidgets('la TrophyCard no está bloqueada (locked=false)', (tester) async {
      await pumpSummary(
        tester,
        trophiesCount: 1,
        latestTrophyLabel: 'Día completado',
      );

      final card = tester.widget<TrophyCard>(find.byType(TrophyCard));
      expect(card.locked, isFalse);
    });
  });

  group('botón de navegación', () {
    testWidgets('el botón "Ver todos los trofeos" existe', (tester) async {
      await pumpSummary(tester);

      expect(find.text('Ver todos los trofeos'), findsOneWidget);
    });

    testWidgets('pulsar el botón navega a TrophiesScreen', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final trophiesProvider = TrophiesProvider(
        TrophyRepository(FakeTrophyDataSourceFull()),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: trophiesProvider,
          child: MaterialApp(
            home: Scaffold(
              body: TrophiesSummary(
                trophiesCount: 2,
                latestTrophyLabel: 'Día completado',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver todos los trofeos'));
      await tester.pumpAndSettle();

      // Verifica que el encabezado de TrophiesScreen aparece
      expect(find.text('Trofeos ganados'), findsOneWidget);
    });
  });
}
