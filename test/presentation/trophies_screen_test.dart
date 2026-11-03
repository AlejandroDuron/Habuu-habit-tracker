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

  Future<void> pump(WidgetTester t, {
    List<Trophy>? all,
    List<EarnedTrophy>? earned,
    bool fail = false,
  }) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final p = TrophiesProvider(TrophyRepository(FakeTrophyDataSourceFull(
      allTrophies: all,
      earnedTrophies: earned,
      shouldFail: fail,
    )));
    await t.pumpWidget(ChangeNotifierProvider.value(
      value: p,
      child: const MaterialApp(home: TrophiesScreen()),
    ));
    await t.pumpAndSettle();
  }

  testWidgets('muestra encabezados de sección', (t) async {
    await pump(t);
    expect(find.text('Trofeos ganados'), findsOneWidget);
    expect(find.text('Trofeos por ganar'), findsOneWidget);
  });

  testWidgets('sin earned muestra mensaje vacío', (t) async {
    await pump(t, all: [], earned: []);
    expect(find.text('Aún no has ganado trofeos. ¡Sigue así!'), findsOneWidget);
  });

  testWidgets('earned aparece como TrophyCard unlocked', (t) async {
    final trophy = buildTrophy(id: 'day_completed', name: 'Día completado');
    await pump(t,
      all: [trophy],
      earned: [buildEarnedTrophy(trophy: trophy)],
    );
    final card = t.widget<TrophyCard>(find.byType(TrophyCard).first);
    expect(card.locked, isFalse);
  });

  testWidgets('locked aparece como TrophyCard bloqueado', (t) async {
    await pump(t,
      all: [buildTrophy(id: 'streak_7', name: 'Racha 7')],
      earned: [],
    );
    final card = t.widget<TrophyCard>(find.byType(TrophyCard).first);
    expect(card.locked, isTrue);
  });

  testWidgets('error muestra botón Reintentar con mensaje correcto', (t) async {
    await pump(t, fail: true);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('No se pudieron cargar los trofeos'), findsOneWidget);
  });
}
