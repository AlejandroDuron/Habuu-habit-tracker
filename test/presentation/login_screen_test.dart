// pantalla de login con el repository fake: validación, carga, errores y
// navegación con el teclado

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';
import 'package:habuu/presentation/screens/auth/login/login_screen.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_auth_repository.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  late FakeAuthRepository repository;
  late AuthProvider auth;

  setUp(() {
    repository = FakeAuthRepository()
      ..addAccount('ana@correo.com', 'Habuu2026!');
  });

  Future<void> openLogin(WidgetTester tester) async {
    // Se crea dentro de la prueba para que los eventos del stream corran con
    // el reloj falso de testWidgets
    auth = AuthProvider(repository);
    addTearDown(auth.dispose);

    // Alta para que el botón quede visible sin hacer scroll
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  final emailField = find.byType(TextFormField).at(0);
  final passwordField = find.byType(TextFormField).at(1);
  final loginButton = find.byType(AuthButton);

  testWidgets('con el formulario vacío muestra los errores y no llama', (
    tester,
  ) async {
    await openLogin(tester);

    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(repository.signInCalls, 0);
  });

  testWidgets('avisa del correo mal escrito mientras se escribe', (
    tester,
  ) async {
    await openLogin(tester);

    await tester.enterText(emailField, 'ana@correo');
    await tester.pump();

    expect(find.text('Ingresa un correo válido'), findsOneWidget);
  });

  testWidgets('mientras espera, el botón muestra carga y no se puede tocar', (
    tester,
  ) async {
    repository.hold = Completer<void>();
    await openLogin(tester);

    await tester.enterText(emailField, 'ana@correo.com');
    await tester.enterText(passwordField, 'Habuu2026!');
    await tester.tap(loginButton);
    await tester.pump();

    expect(
      find.descendant(
        of: loginButton,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    final button = tester.widget<ElevatedButton>(
      find.descendant(of: loginButton, matching: find.byType(ElevatedButton)),
    );
    expect(button.onPressed, isNull);

    repository.hold!.complete();
    await tester.pump();
    await tester.pump();
    expect(auth.isLoading, isFalse);
    expect(auth.isAuthenticated, isTrue);
  });

  testWidgets('con la contraseña mala muestra el error traducido', (
    tester,
  ) async {
    await openLogin(tester);

    await tester.enterText(emailField, 'ana@correo.com');
    await tester.enterText(passwordField, 'OtraClave1!');
    await tester.tap(loginButton);
    await tester.pump();
    await tester.pump();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(auth.isAuthenticated, isFalse);
  });

  testWidgets('"siguiente" pasa a la contraseña y "listo" envía', (
    tester,
  ) async {
    await openLogin(tester);

    await tester.enterText(emailField, 'ana@correo.com');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    final passwordInput = tester.widget<EditableText>(
      find.descendant(of: passwordField, matching: find.byType(EditableText)),
    );
    expect(passwordInput.focusNode.hasFocus, isTrue);

    await tester.enterText(passwordField, 'Habuu2026!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(repository.signInCalls, 1);
  });
}
