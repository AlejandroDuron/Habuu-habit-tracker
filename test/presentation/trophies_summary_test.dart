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
  setUpAll(() async => initializeDateFormatting('es_ES'));

  Future<void> pump(WidgetTester t, {int count = 0, String label = ''}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final p = TrophiesProvider(TrophyRepository(FakeTrophyDataSourceFull()));
    await t.pumpWidget(ChangeNotifierProvider.value(
      value: p,
      child: MaterialApp(
        home: Scaffold(
          body: TrophiesSummary(trophiesCount: count, latestTrophyLabel: label),
        ),
      ),
    ));
    await t.pumpAndSettle();
  }

  testWidgets('sin trofeos muestra mensaje vacío', (t) async {
    await pump(t, count: 0);
    expect(find.text('Aún no has ganado trofeos'), findsOneWidget);
    expect(find.byType(TrophyCard), findsNothing);
  });

  testWidgets('con trofeos muestra TrophyCard con el label', (t) async {
    await pump(t, count: 1, label: 'Racha de 7 días');
    expect(find.byType(TrophyCard), findsOneWidget);
    expect(find.text('Racha de 7 días'), findsOneWidget);
  });

  testWidgets('botón "Ver todos los trofeos" siempre presente', (t) async {
    await pump(t);
    expect(find.text('Ver todos los trofeos'), findsOneWidget);
  });
}
