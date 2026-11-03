// el AuthGate decide la pantalla según la sesión. Se arma con AppProviders
// igual que en main(), pero con el repository fake y sin los datos de Supabase

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/config/app_providers.dart';
import 'package:habuu/config/routes.dart';
import 'package:habuu/data/models/app_user.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';
import 'package:habuu/presentation/screens/auth/auth_gate.dart';
import 'package:habuu/presentation/screens/auth/login/login_screen.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_auth_repository.dart';

const _ana = AppUser(id: 'u1', email: 'ana@correo.com', name: 'Ana');

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  final home = find.text('Pantalla del home');
  // Botón de la landing
  final createAccount = find.text('Crear cuenta');

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> openApp(WidgetTester tester, FakeAuthRepository repo) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppProviders(
        authRepository: repo,
        userDataScope: (app) => app,
        child: MaterialApp(
          routes: AppRoutes.routes,
          home: const AuthGate(home: Scaffold(body: Text('Pantalla del home'))),
        ),
      ),
    );
    await tester.pump();
  }

  /// El provider que creó AppProviders.
  AuthProvider authOf(WidgetTester tester) => Provider.of<AuthProvider>(
    tester.element(find.byType(Navigator).first),
    listen: false,
  );

  /// Deja pasar el cambio de sesión y las transiciones.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('mientras no sabe si hay sesión muestra carga, no la landing', (
    tester,
  ) async {
    final repo = FakeAuthRepository(emitsOnListen: false);
    await openApp(tester, repo);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(createAccount, findsNothing);

    repo.emit(null);
    await settle(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(createAccount, findsOneWidget);
  });

  testWidgets('con una sesión guardada entra directo al home', (tester) async {
    await openApp(tester, FakeAuthRepository(user: _ana));
    await settle(tester);

    expect(home, findsOneWidget);
    expect(createAccount, findsNothing);
  });

  testWidgets('al iniciar sesión cambia al home y quita la pantalla de login', (
    tester,
  ) async {
    final repo = FakeAuthRepository()
      ..addAccount('ana@correo.com', 'Habuu2026!');
    await openApp(tester, repo);
    await settle(tester);

    await tester.tap(find.text('Iniciar sesión'));
    await settle(tester);
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ana@correo.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Habuu2026!');
    await tester.tap(find.byType(AuthButton));
    await settle(tester);

    expect(home, findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('al cerrar sesión vuelve a la landing', (tester) async {
    await openApp(tester, FakeAuthRepository(user: _ana));
    await settle(tester);
    expect(home, findsOneWidget);

    await authOf(tester).logout();
    await settle(tester);

    expect(home, findsNothing);
    expect(createAccount, findsOneWidget);
  });

  testWidgets('la sesión temporal de recuperar contraseña no abre el home', (
    tester,
  ) async {
    await openApp(tester, FakeAuthRepository());
    await settle(tester);

    final auth = authOf(tester);
    await auth.requestPasswordReset('ana@correo.com');
    await auth.verifyCode('123456');
    await settle(tester);

    expect(home, findsNothing);
    expect(createAccount, findsOneWidget);
  });

  testWidgets('cuenta nueva: "Cuenta verificada", onboarding y luego home', (
    tester,
  ) async {
    // El onboarding se desborda unos píxeles con la fuente cuadrada que usan
    // las pruebas. Eso no es lo que se prueba aquí, así que se ignora solo
    // ese error.
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      onError?.call(details);
    };

    await openApp(tester, FakeAuthRepository());
    await settle(tester);

    final auth = authOf(tester);
    await auth.register(
      name: 'Ana',
      email: 'ana@correo.com',
      password: 'Habuu2026!',
    );
    await auth.verifyCode('123456');
    await settle(tester);

    expect(find.text('Cuenta verificada\ncon éxito'), findsOneWidget);
    expect(home, findsNothing);

    // La pantalla de verificada avanza sola a los 2 segundos
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(find.text('Omitir'), findsOneWidget);

    await tester.tap(find.text('Omitir'));
    await settle(tester);
    expect(home, findsOneWidget);

    FlutterError.onError = onError;
  });
}
