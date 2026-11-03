import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/screens/landing/onboarding_screen.dart';

void main() {
  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('onboarding advances through all pages and finishes', (
    tester,
  ) async {
    setViewport(tester, const Size(360, 640));
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(onFinish: () => finished = true)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Construye hábitos que\ntransformen tu día'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Mantén tus rachas\npara ganar trofeos'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Establece\nrecordatorios'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('¡Empezemos!'));
    await tester.pump();
    expect(finished, isTrue);
  });

  testWidgets('onboarding skip calls onFinish', (tester) async {
    setViewport(tester, const Size(360, 640));
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(onFinish: () => finished = true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Omitir'));
    await tester.pump();

    expect(finished, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding renders at a compact 320x568 viewport', (
    tester,
  ) async {
    setViewport(tester, const Size(320, 568));

    await tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(onFinish: _onFinish)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siguiente'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _onFinish() {}
