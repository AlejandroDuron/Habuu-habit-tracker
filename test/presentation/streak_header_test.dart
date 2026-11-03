// AnimatedFrog tiene animaciones infinitas → se usa pump(duration).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/presentation/widgets/streaks/streak_header.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<void> pump(WidgetTester t, {int count = 0}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: StreakHeader(streakCount: count, frogAwake: false)),
    ));
    await t.pump(const Duration(milliseconds: 500));
  }

  testWidgets('muestra "Días de racha" en plural', (t) async {
    await pump(t, count: 5);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Días de racha'), findsOneWidget);
  });

  testWidgets('singular con racha de 1', (t) async {
    await pump(t, count: 1);
    expect(find.text('Día de racha'), findsOneWidget);
  });

  testWidgets('dormida muestra mensaje de dormir', (t) async {
    await pump(t);
    expect(find.text('Completa un hábito para despertar a Froggy'), findsOneWidget);
  });

  testWidgets('despierta muestra mensaje hopping', (t) async {
    // Maneja el timer de 10 s manualmente para no dejarlo pendiente
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: const StreakHeader(streakCount: 5, frogAwake: true)),
    ));
    await t.pump(const Duration(milliseconds: 400));

    expect(find.text('¡Froggy ha despertado, sigue así!'), findsOneWidget);

    await t.pump(const Duration(seconds: 10, milliseconds: 400));
  });
}
