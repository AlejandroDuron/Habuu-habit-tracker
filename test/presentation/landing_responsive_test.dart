import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/presentation/screens/landing/landing_screen.dart';
import 'package:habuu/presentation/screens/landing/onboarding_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void setMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('landing fits a 360x640 viewport', (tester) async {
    setMobileViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding pages fit a 360x640 viewport', (tester) async {
    setMobileViewport(tester);

    await tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(onFinish: _onFinish)),
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
  });
}

void _onFinish() {}
