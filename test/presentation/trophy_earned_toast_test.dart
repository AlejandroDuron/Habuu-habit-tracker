import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/trophy.dart';
import 'package:habuu/presentation/widgets/thophies/trophy_earned_toast.dart';

void main() {
  EarnedTrophy earned({String name = 'Día completado', String? key = 'day_completed'}) =>
      EarnedTrophy(trophy: Trophy(id: 'x', name: name, key: key), earnedAt: DateTime(2026, 11, 2));

  Future<void> pump(WidgetTester t, EarnedTrophy trophy, {VoidCallback? onDismissed}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: Stack(children: [
        TrophyEarnedToast(trophy: trophy, onDismissed: onDismissed ?? () {}),
      ])),
    ));
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets('muestra el nombre del trofeo y "¡Trofeo ganado!"', (t) async {
    await pump(t, earned(name: 'Racha de 7 días'));
    expect(find.text('¡Trofeo ganado!'), findsOneWidget);
    expect(find.text('Racha de 7 días'), findsOneWidget);
    await t.pump(const Duration(seconds: 3, milliseconds: 600));
  });

  testWidgets('botón de cierre está presente', (t) async {
    await pump(t, earned());
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await t.pump(const Duration(seconds: 3, milliseconds: 600));
  });

  testWidgets('auto-dismiss llama a onDismissed tras 3 s', (t) async {
    var dismissed = false;
    await pump(t, earned(), onDismissed: () => dismissed = true);
    await t.pump(const Duration(seconds: 3));
    await t.pump(const Duration(milliseconds: 600));
    expect(dismissed, isTrue);
  });

  testWidgets('key null no lanza excepción', (t) async {
    await pump(t, earned(key: null));
    expect(t.takeException(), isNull);
    await t.pump(const Duration(seconds: 3, milliseconds: 600));
  });
}
