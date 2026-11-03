// el provider de autenticación con el repository fake: estados de carga,
// errores y los flujos de registro y recuperación

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/app_user.dart';
import 'package:habuu/data/repositories/auth_repository.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';

import '../fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthProvider auth;

  setUp(() {
    repository = FakeAuthRepository();
    auth = AuthProvider(repository);
  });

  tearDown(() => auth.dispose());

  test('arranca con la sesión que ya estaba guardada', () {
    final saved = AuthProvider(
      FakeAuthRepository(
        user: const AppUser(id: 'u1', email: 'ana@correo.com', name: 'Ana'),
      ),
    );
    addTearDown(saved.dispose);

    expect(saved.isAuthenticated, isTrue);
    expect(saved.userId, 'u1');
    expect(saved.userName, 'Ana');
  });

  test('sin nombre guardado, lo saca del correo', () async {
    repository.emit(const AppUser(id: 'u1', email: 'luis@correo.com'));
    await pumpEventQueue();

    expect(auth.userName, 'Luis');
  });

  group('login', () {
    test('con la contraseña correcta queda dentro', () async {
      repository.addAccount('ana@correo.com', 'Habuu2026!');

      final ok = await auth.login(
        email: ' ana@correo.com ',
        password: 'Habuu2026!',
      );
      await pumpEventQueue();

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.errorMessage, isNull);
    });

    test('si falla, guarda el mensaje y no entra', () async {
      final ok = await auth.login(email: 'ana@correo.com', password: 'mala');

      expect(ok, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, 'Correo o contraseña incorrectos.');
    });

    test('isLoading está encendido solo mientras espera', () async {
      repository
        ..addAccount('ana@correo.com', 'Habuu2026!')
        ..hold = Completer<void>();

      final future = auth.login(
        email: 'ana@correo.com',
        password: 'Habuu2026!',
      );
      expect(auth.isLoading, isTrue);

      repository.hold!.complete();
      await future;
      expect(auth.isLoading, isFalse);
    });

    test('un segundo toque mientras carga no hace otra llamada', () async {
      repository.hold = Completer<void>();

      final first = auth.login(email: 'a@b.com', password: 'Habuu2026!');
      final second = await auth.login(email: 'a@b.com', password: 'Habuu2026!');
      repository.hold!.complete();
      await first;

      expect(second, isFalse);
      expect(repository.signInCalls, 1);
    });

    test('un error inesperado se muestra con el mensaje genérico', () async {
      final broken = AuthProvider(_ThrowingRepository());
      addTearDown(broken.dispose);

      final ok = await broken.login(email: 'a@b.com', password: 'x');

      expect(ok, isFalse);
      expect(broken.errorMessage, 'Algo salió mal. Inténtalo de nuevo.');
    });
  });

  group('registro con confirmación de correo', () {
    test('queda esperando el código y todavía no entra', () async {
      final ok = await auth.register(
        name: 'Ana',
        email: 'ana@correo.com',
        password: 'Habuu2026!',
      );

      expect(ok, isTrue);
      expect(auth.isWaitingForCode, isTrue);
      expect(auth.pendingEmail, 'ana@correo.com');
      expect(auth.isAuthenticated, isFalse);
      expect(auth.showWelcome, isFalse);
    });

    test('el código correcto inicia sesión y pide la bienvenida', () async {
      await auth.register(
        name: 'Ana',
        email: 'ana@correo.com',
        password: 'Habuu2026!',
      );

      final ok = await auth.verifyCode('123456');
      await pumpEventQueue();

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.showWelcome, isTrue);
      expect(auth.isWaitingForCode, isFalse);

      auth.finishWelcome();
      expect(auth.showWelcome, isFalse);
    });

    test('un código incorrecto no inicia sesión ni pide bienvenida', () async {
      await auth.register(
        name: 'Ana',
        email: 'ana@correo.com',
        password: 'Habuu2026!',
      );

      final ok = await auth.verifyCode('000000');

      expect(ok, isFalse);
      expect(auth.errorMessage, contains('Código incorrecto'));
      expect(auth.showWelcome, isFalse);
      expect(auth.isWaitingForCode, isTrue);
    });
  });

  test('registro sin confirmación de correo entra directo', () async {
    repository = FakeAuthRepository(requiresCode: false);
    auth = AuthProvider(repository);

    await auth.register(
      name: 'Ana',
      email: 'ana@correo.com',
      password: 'Habuu2026!',
    );
    await pumpEventQueue();

    expect(auth.isAuthenticated, isTrue);
    expect(auth.showWelcome, isTrue);
    expect(auth.isWaitingForCode, isFalse);
  });

  group('recuperar contraseña', () {
    test('la sesión temporal no cuenta como dentro de la app', () async {
      await auth.requestPasswordReset('ana@correo.com');
      await auth.verifyCode('123456');
      await pumpEventQueue();

      expect(auth.isRecoveringPassword, isTrue);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.userId, isNull);
    });

    test('cambiar la contraseña cierra la sesión temporal', () async {
      await auth.requestPasswordReset('ana@correo.com');
      await auth.verifyCode('123456');

      final ok = await auth.changePassword('Nueva2026!');
      await pumpEventQueue();

      expect(ok, isTrue);
      expect(repository.lastPassword, 'Nueva2026!');
      expect(repository.signOutCalls, 1);
      expect(auth.isRecoveringPassword, isFalse);
      expect(auth.isAuthenticated, isFalse);
    });

    test('no deja cambiarla sin verificar el código', () async {
      await auth.requestPasswordReset('ana@correo.com');

      final ok = await auth.changePassword('Nueva2026!');

      expect(ok, isFalse);
      expect(auth.errorMessage, 'Primero verifica el código.');
    });

    test('una recuperación a medias no bloquea el login', () async {
      repository.addAccount('ana@correo.com', 'Habuu2026!');
      await auth.requestPasswordReset('ana@correo.com');
      await auth.verifyCode('123456');

      await auth.login(email: 'ana@correo.com', password: 'Habuu2026!');
      await pumpEventQueue();

      expect(auth.isRecoveringPassword, isFalse);
      expect(auth.isAuthenticated, isTrue);
    });
  });

  test('logout cierra la sesión', () async {
    repository.emit(const AppUser(id: 'u1', email: 'ana@correo.com'));
    await pumpEventQueue();

    await auth.logout();
    await pumpEventQueue();

    expect(repository.signOutCalls, 1);
    expect(auth.isAuthenticated, isFalse);
    expect(auth.userId, isNull);
  });
}

/// Repository que falla con algo que no es un [AuthFailure].
class _ThrowingRepository extends FakeAuthRepository {
  @override
  Future<void> signIn({required String email, required String password}) {
    throw StateError('se cayó');
  }
}
