// pantalla de registro con el repository fake

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/repositories/auth_error_messages.dart';
import 'package:habuu/data/repositories/auth_repository.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';
import 'package:habuu/presentation/screens/auth/register/register_screen.dart';
import 'package:habuu/presentation/screens/auth/verification/code_verification_screen.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_auth_repository.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  late FakeAuthRepository repository;
  late AuthProvider auth;

  setUp(() {
    repository = FakeAuthRepository();
  });

  Future<void> openRegister(WidgetTester tester) async {
    // Se crea dentro de la prueba para que los eventos del stream corran con
    // el reloj falso de testWidgets
    auth = AuthProvider(repository);
    addTearDown(auth.dispose);

    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
  }

  final fields = find.byType(TextFormField);
  final createButton = find.byType(AuthButton);

  Future<void> fillForm(
    WidgetTester tester, {
    String password = 'Habuu2026!',
    String confirm = 'Habuu2026!',
  }) async {
    await tester.enterText(fields.at(0), 'Ana');
    await tester.enterText(fields.at(1), 'ana@correo.com');
    await tester.enterText(fields.at(2), password);
    await tester.enterText(fields.at(3), confirm);
  }

  testWidgets('si la confirmación no coincide, no se crea la cuenta', (
    tester,
  ) async {
    await openRegister(tester);
    await fillForm(tester, confirm: 'Habuu2026?');

    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(repository.lastPassword, isNull);
  });

  testWidgets('una contraseña sin símbolo no pasa', (tester) async {
    await openRegister(tester);
    await fillForm(tester, password: 'Habuu2026', confirm: 'Habuu2026');

    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('La contraseña no cumple los requisitos'), findsOneWidget);
    expect(repository.lastPassword, isNull);
  });

  testWidgets('con todo bien, lleva a la pantalla del código', (tester) async {
    await openRegister(tester);
    await fillForm(tester);

    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.byType(CodeVerificationScreen), findsOneWidget);
    expect(auth.pendingEmail, 'ana@correo.com');
  });

  testWidgets('correo ya registrado: muestra el error y se queda', (
    tester,
  ) async {
    repository.nextError = const AuthFailure(emailTakenAuthError);
    await openRegister(tester);
    await fillForm(tester);

    await tester.tap(createButton);
    await tester.pump();
    await tester.pump();

    expect(find.text(emailTakenAuthError), findsOneWidget);
    expect(find.byType(CodeVerificationScreen), findsNothing);
  });

  testWidgets('desde el teclado recorre los cuatro campos y envía', (
    tester,
  ) async {
    await openRegister(tester);

    await tester.enterText(fields.at(0), 'Ana');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.enterText(fields.at(1), 'ana@correo.com');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.enterText(fields.at(2), 'Habuu2026!');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.enterText(fields.at(3), 'Habuu2026!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.lastPassword, 'Habuu2026!');
    expect(find.byType(CodeVerificationScreen), findsOneWidget);
  });
}
