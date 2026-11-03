// Tests de widget para StreakHeader.
// Se verifica el número de días, el texto singular/plural,
// los mensajes de Froggy según frogAwake, y la imagen decorativa.
//
// NOTA: AnimatedFrog usa animaciones infinitas (breathe/hop), lo que impide
// usar pumpAndSettle(). Todos los tests usan pump(duration).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/presentation/widgets/streaks/streak_header.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  /// Tiempo suficiente para que el widget reconstruya sin esperar
  /// que las animaciones infinitas de Froggy terminen.
  const settle = Duration(milliseconds: 300);

  /// Monta el StreakHeader con los parámetros dados y avanza [settle].
  Future<void> pumpHeader(
    WidgetTester tester, {
    int streakCount = 0,
    bool frogAwake = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StreakHeader(
            streakCount: streakCount,
            frogAwake: frogAwake,
          ),
        ),
      ),
    );
    await tester.pump(settle);
  }

  group('número de días', () {
    testWidgets('muestra "0 Días de racha" con racha cero', (tester) async {
      await pumpHeader(tester, streakCount: 0);

      expect(find.text('0'), findsOneWidget);
      expect(find.text('Días de racha'), findsOneWidget);
    });

    testWidgets('muestra "1 Día de racha" en singular', (tester) async {
      await pumpHeader(tester, streakCount: 1);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Día de racha'), findsOneWidget);
    });

    testWidgets('muestra "21 Días de racha" en plural', (tester) async {
      await pumpHeader(tester, streakCount: 21);

      expect(find.text('21'), findsOneWidget);
      expect(find.text('Días de racha'), findsOneWidget);
    });
  });

  group('mensajes de Froggy', () {
    testWidgets('sin racha ni hábitos → mensaje de dormir', (tester) async {
      await pumpHeader(tester, frogAwake: false);

      expect(
        find.text('Completa un hábito para despertar a Froggy'),
        findsOneWidget,
      );
    });

    testWidgets('con frogAwake=true → mensaje de bienvenida', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakHeader(streakCount: 5, frogAwake: true),
          ),
        ),
      );
      // Avanzamos la animación de entrada del AnimatedSwitcher (400 ms)
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('¡Froggy ha despertado, sigue así!'), findsOneWidget);

      // Avanza el timer interno de 10 s para que no quede pendiente
      await tester.pump(const Duration(seconds: 10, milliseconds: 400));
    });
  });

  group('imagen decorativa de streak', () {
    testWidgets('NO aparece la imagen decorativa cuando frogAwake=false',
        (tester) async {
      await pumpHeader(tester, frogAwake: false);

      final images = tester.widgetList<Image>(find.byType(Image));
      final decorative = images.where(
        (img) =>
            img.image is AssetImage &&
            (img.image as AssetImage).assetName.contains('streak_7'),
      );
      expect(decorative, isEmpty);
    });

    testWidgets('SÍ aparece la imagen decorativa cuando frogAwake=true',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakHeader(streakCount: 5, frogAwake: true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      final images = tester.widgetList<Image>(find.byType(Image));
      final decorative = images.where(
        (img) =>
            img.image is AssetImage &&
            (img.image as AssetImage).assetName.contains('streak_7'),
      );
      expect(decorative.isNotEmpty, isTrue);

      // Limpia el timer de 10 s
      await tester.pump(const Duration(seconds: 10, milliseconds: 400));
    });
  });

  group('transición de estado', () {
    testWidgets(
        'al cambiar frogAwake de false a true se muestra el mensaje hopping',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // Monta en estado dormido
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakHeader(streakCount: 3, frogAwake: false),
          ),
        ),
      );
      await tester.pump(settle);
      expect(
        find.text('Completa un hábito para despertar a Froggy'),
        findsOneWidget,
      );

      // Actualiza a despierto
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakHeader(streakCount: 3, frogAwake: true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('¡Froggy ha despertado, sigue así!'), findsOneWidget);

      // Limpia el timer de 10 s
      await tester.pump(const Duration(seconds: 10, milliseconds: 400));
    });
  });
}
