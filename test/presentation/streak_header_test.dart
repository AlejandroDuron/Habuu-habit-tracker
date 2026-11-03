// AnimatedFrog tiene animaciones infinitas → se usa pump(duration).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/presentation/widgets/streaks/streak_header.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  /// Monta el header en estado durmiente (awake=false, racha=0) y avanza
  /// 500 ms para que el AnimatedSwitcher (400 ms) termine.
  Future<void> pump(WidgetTester t, {int count = 0}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: StreakHeader(streakCount: count, frogAwake: false)),
    ));
    await t.pump(const Duration(milliseconds: 500));
  }

  group('número de días', () {
    testWidgets('muestra "Días de racha" en plural', (t) async {
      await pump(t, count: 5);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Días de racha'), findsOneWidget);
    });

    testWidgets('singular con racha de 1', (t) async {
      await pump(t, count: 1);
      expect(find.text('Día de racha'), findsOneWidget);
    });
  });

  group('estados de Froggy', () {
    testWidgets('dormida: muestra mensaje de dormir', (t) async {
      // pump() ya usa frogAwake=false por defecto
      await pump(t);
      expect(find.text('Completa un hábito para despertar a Froggy'), findsOneWidget);
    });

    testWidgets('hopping: al activar frogAwake muestra mensaje de salto', (t) async {
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: Scaffold(body: const StreakHeader(streakCount: 3, frogAwake: true)),
      ));
      await t.pump(const Duration(milliseconds: 400));

      expect(find.text('¡Froggy ha despertado, sigue así!'), findsOneWidget);

      // Drena el timer de 10 s
      await t.pump(const Duration(seconds: 10, milliseconds: 400));
    });

    testWidgets('milestone: racha ≥ 7 muestra mensaje de celebración', (t) async {
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: Scaffold(body: const StreakHeader(streakCount: 7, frogAwake: true)),
      ));
      await t.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('7 días de racha'), findsOneWidget);

      // Drena el timer de 10 s
      await t.pump(const Duration(seconds: 10, milliseconds: 400));
    });

    testWidgets('milestone vuelve a resting tras 10 s', (t) async {
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: Scaffold(body: const StreakHeader(streakCount: 7, frogAwake: true)),
      ));
      await t.pump(const Duration(milliseconds: 400));
      // Esperamos que pase el timer del milestone
      await t.pump(const Duration(seconds: 10, milliseconds: 400));

      expect(find.text('¡Sigue así, vas muy bien!'), findsOneWidget);
    });
  });
}

