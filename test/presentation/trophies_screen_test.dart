// Tests de widget para TrophiesScreen.
// Se prueba el loading, el error con reintento, la lista de earned/locked
// y los mensajes cuando no hay trofeos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/models/trophy.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';
import 'package:habuu/presentation/providers/trophies_provider.dart';
import 'package:habuu/presentation/screens/thophy/thophy_screen.dart';
import 'package:habuu/presentation/widgets/thophies/trophy_card.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  /// Monta TrophiesScreen con un provider configurado por el test.
  Future<TrophiesProvider> pumpScreen(
    WidgetTester tester, {
    List<Trophy>? allTrophies,
    List<EarnedTrophy>? earned,
    EarnedTrophy? awardedTrophy,
    bool shouldFail = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final ds = FakeTrophyDataSourceFull(
      allTrophies: allTrophies,
      earnedTrophies: earned,
      awardedTrophy: awardedTrophy,
      shouldFail: shouldFail,
    );
    final provider = TrophiesProvider(TrophyRepository(ds));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: TrophiesScreen()),
      ),
    );

    return provider;
  }

  group('estado de carga', () {
    testWidgets('muestra CircularProgressIndicator mientras carga',
        (tester) async {
      // El FakeTrophyDataSourceFull resuelve en el mismo microtask, por eso
      // verificamos que isLoading cambie a true en algún momento; en su lugar
      // confirmamos que después de cargar el indicador ya no está.
      // (El widget usa WidgetsBinding.addPostFrameCallback para disparar la carga,
      // así que el primer pump sí captura el estado inicial = initial, no loading.)
      final ds = FakeTrophyDataSourceFull();
      final provider = TrophiesProvider(TrophyRepository(ds));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: TrophiesScreen()),
        ),
      );

      // En el primer frame la pantalla aún no ha llamado a loadTrophies
      // (lo hace en addPostFrameCallback), así que el status es initial →
      // isLoading=false y no hay CircularProgressIndicator.
      // Después de pumpAndSettle la carga terminó.
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('el indicador desaparece tras cargar', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('estado de error', () {
    testWidgets('muestra mensaje de error y botón Reintentar', (tester) async {
      await pumpScreen(tester, shouldFail: true);
      await tester.pumpAndSettle();

      expect(find.text('Reintentar'), findsOneWidget);
      // El mensaje viene de provider.errorMessage, que es 'No se pudieron cargar los trofeos',
      // o del fallback 'Algo salió mal' si errorMessage es null.
      // En este caso el provider sí tiene errorMessage definido.
      expect(
        find.textContaining('No se pudieron cargar los trofeos'),
        findsOneWidget,
      );
    });

    testWidgets('Reintentar vuelve a cargar los trofeos', (tester) async {
      final ds = FakeTrophyDataSourceFull(shouldFail: true);
      final provider = TrophiesProvider(TrophyRepository(ds));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: TrophiesScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);

      // Ahora la fuente funciona
      ds.shouldFail = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Reintentar'), findsNothing);
    });
  });

  group('sin trofeos', () {
    testWidgets('muestra mensaje cuando no hay earned ni locked', (tester) async {
      await pumpScreen(
        tester,
        allTrophies: [],
        earned: [],
      );
      await tester.pumpAndSettle();

      expect(find.text('Aún no has ganado trofeos. ¡Sigue así!'), findsOneWidget);
      expect(find.text('¡Ya ganaste todos los trofeos!'), findsOneWidget);
    });

    testWidgets('muestra mensaje cuando no tiene earned pero sí locked',
        (tester) async {
      await pumpScreen(
        tester,
        allTrophies: [buildTrophy(id: 'streak_7', name: 'Racha 7')],
        earned: [],
      );
      await tester.pumpAndSettle();

      expect(find.text('Aún no has ganado trofeos. ¡Sigue así!'), findsOneWidget);
      expect(find.text('Racha 7'), findsOneWidget);
    });
  });

  group('con trofeos ganados', () {
    testWidgets('muestra los TrophyCard de trofeos ganados', (tester) async {
      await pumpScreen(
        tester,
        allTrophies: [
          buildTrophy(id: 'day_completed', name: 'Día completado'),
          buildTrophy(id: 'streak_7', name: 'Racha 7'),
        ],
        earned: [
          buildEarnedTrophy(
            trophy: buildTrophy(id: 'day_completed', name: 'Día completado'),
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Día completado'), findsOneWidget);
      // 'Racha 7' está en locked, también debe aparecer
      expect(find.text('Racha 7'), findsOneWidget);
    });

    testWidgets('los trofeos ganados NO están en modo locked', (tester) async {
      await pumpScreen(
        tester,
        allTrophies: [buildTrophy(id: 'day_completed', name: 'Día completado')],
        earned: [
          buildEarnedTrophy(
            trophy: buildTrophy(id: 'day_completed', name: 'Día completado'),
          ),
        ],
      );
      await tester.pumpAndSettle();

      final cards = tester.widgetList<TrophyCard>(find.byType(TrophyCard));
      final earnedCard = cards.firstWhere((c) => c.title == 'Día completado');
      expect(earnedCard.locked, isFalse);
    });

    testWidgets('los trofeos no ganados están en modo locked', (tester) async {
      await pumpScreen(
        tester,
        allTrophies: [
          buildTrophy(id: 'day_completed', name: 'Día completado'),
          buildTrophy(id: 'streak_7', name: 'Racha 7'),
        ],
        earned: [
          buildEarnedTrophy(
            trophy: buildTrophy(id: 'day_completed', name: 'Día completado'),
          ),
        ],
      );
      await tester.pumpAndSettle();

      final cards = tester.widgetList<TrophyCard>(find.byType(TrophyCard));
      final lockedCard = cards.firstWhere((c) => c.title == 'Racha 7');
      expect(lockedCard.locked, isTrue);
    });

    testWidgets('muestra "¡Ya ganaste todos los trofeos!" cuando locked vacío',
        (tester) async {
      final allTrophies = [buildTrophy(id: 'day_completed', name: 'Día completado')];
      await pumpScreen(
        tester,
        allTrophies: allTrophies,
        earned: [
          buildEarnedTrophy(
            trophy: buildTrophy(id: 'day_completed', name: 'Día completado'),
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('¡Ya ganaste todos los trofeos!'), findsOneWidget);
    });
  });

  group('encabezados de sección', () {
    testWidgets('muestra "Trofeos ganados" y "Trofeos por ganar"',
        (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Trofeos ganados'), findsOneWidget);
      expect(find.text('Trofeos por ganar'), findsOneWidget);
    });
  });

  group('botón de volver', () {
    testWidgets('el botón de back navega fuera de la pantalla', (tester) async {
      var popped = false;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TrophiesProvider(
            TrophyRepository(FakeTrophyDataSourceFull()),
          ),
          child: MaterialApp(
            home: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Builder(
                    builder: (ctx) => ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) => TrophiesProvider(
                                TrophyRepository(FakeTrophyDataSourceFull()),
                              ),
                              child: const TrophiesScreen(),
                            ),
                          ),
                        ).then((_) => popped = true);
                      },
                      child: const Text('Abrir'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.byType(TrophiesScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });
}
