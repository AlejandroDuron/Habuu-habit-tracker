import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/presentation/screens/landing/landing_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('landing buttons call their callbacks at 360x640', (
    tester,
  ) async {
    setViewport(tester, const Size(360, 640));
    var loginTapped = false;
    var registerTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          onLogin: () => loginTapped = true,
          onCreateAccount: () => registerTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    expect(loginTapped, isTrue);

    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();
    expect(registerTapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landing renders at a compact 320x568 viewport', (tester) async {
    setViewport(tester, const Size(320, 568));

    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
