// Tests de widget para TrophyEarnedToast.
// Verifica que el toast muestra el nombre del trofeo, el botón de cierre,
// y que llama al callback cuando el usuario lo cierra manualmente.
//
// NOTA: el toast usa un Timer de 3 s y animaciones que requieren avanzar
// el tiempo con pump(). Todos los tests avansan el tiempo explícitamente
// para evitar timers pendientes al final del test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/trophy.dart';
import 'package:habuu/presentation/widgets/thophies/trophy_earned_toast.dart';

void main() {
  EarnedTrophy buildEarned({
    String id = 'day_completed',
    String name = 'Día completado',
    String? key = 'day_completed',
  }) =>
      EarnedTrophy(
        trophy: Trophy(id: id, name: name, key: key),
        earnedAt: DateTime(2026, 11, 2),
      );

  /// Monta el toast y avanza la animación de entrada (400 ms).
  /// Al final avanza los 3 s del auto-dismiss para no dejar timers pendientes.
  Future<void> pumpToast(
    WidgetTester tester, {
    required EarnedTrophy trophy,
    required VoidCallback onDismissed,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              TrophyEarnedToast(trophy: trophy, onDismissed: onDismissed),
            ],
          ),
        ),
      ),
    );
    // Avanza la animación de entrada
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('contenido', () {
    testWidgets('muestra "¡Trofeo ganado!" y el nombre del trofeo',
        (tester) async {
      await pumpToast(
        tester,
        trophy: buildEarned(name: 'Racha de 7 días'),
        onDismissed: () {},
      );

      expect(find.text('¡Trofeo ganado!'), findsOneWidget);
      expect(find.text('Racha de 7 días'), findsOneWidget);

      // Limpia el timer auto-dismiss (3 s + 400 ms animación salida)
      await tester.pump(const Duration(seconds: 3, milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('muestra el botón de cierre', (tester) async {
      await pumpToast(
        tester,
        trophy: buildEarned(),
        onDismissed: () {},
      );

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.pump(const Duration(seconds: 3, milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('funciona con trophy.key null (usa imagen por defecto)',
        (tester) async {
      await pumpToast(
        tester,
        trophy: buildEarned(key: null),
        onDismissed: () {},
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Día completado'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3, milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('cierre manual', () {
    testWidgets('tocar el botón de cierre llama a onDismissed', (tester) async {
      var dismissed = false;
      await pumpToast(
        tester,
        trophy: buildEarned(),
        onDismissed: () => dismissed = true,
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      // _dismiss() hace reverse() del controller (400 ms) y luego llama al callback
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 100));

      expect(dismissed, isTrue);
    });
  });

  group('auto-dismiss', () {
    testWidgets('llama a onDismissed automáticamente tras 3 segundos',
        (tester) async {
      var dismissed = false;
      await pumpToast(
        tester,
        trophy: buildEarned(),
        onDismissed: () => dismissed = true,
      );

      // Avanza 3 s (visibilidad) + 400 ms (animación salida) + margen
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));

      expect(dismissed, isTrue);
    });
  });
}
