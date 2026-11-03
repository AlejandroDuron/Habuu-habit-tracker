// cuentas guardadas en memoria, sin red. Sirve para las pruebas del provider,
// de las pantallas de login/registro y del AuthGate

import 'dart:async';

import 'package:habuu/data/models/app_user.dart';
import 'package:habuu/data/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this._user,
    this.requiresCode = true,
    this.validCode = '123456',
    this.emitsOnListen = true,
  });

  /// Si es false, el registro inicia sesión directo (sin confirmar correo).
  final bool requiresCode;
  final String validCode;

  /// Si es false, el stream no emite nada hasta que se llame a [emit], como
  /// cuando Supabase todavía no termina de leer la sesión guardada.
  final bool emitsOnListen;

  final _changes = StreamController<AppUser?>.broadcast();
  final _passwords = <String, String>{};
  AppUser? _user;

  /// Si no es null, la próxima llamada falla con este error.
  AuthFailure? nextError;

  /// Si no es null, las llamadas esperan a que se complete. Sirve para ver
  /// el estado de carga.
  Completer<void>? hold;

  int signInCalls = 0;
  int signOutCalls = 0;
  String? lastPassword;

  void addAccount(String email, String password) {
    _passwords[email] = password;
  }

  /// Simula un cambio de sesión que viene de fuera (por ejemplo, al abrir
  /// la app con una sesión guardada).
  void emit(AppUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() => Stream.multi((listener) {
    if (emitsOnListen) listener.add(_user);
    final subscription = _changes.stream.listen(listener.add);
    listener.onCancel = subscription.cancel;
  });

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    await _step();
    if (_passwords[email.trim()] != password) {
      throw const AuthFailure('Correo o contraseña incorrectos.');
    }
    emit(AppUser(id: 'id-$email', email: email.trim()));
  }

  @override
  Future<SignUpOutcome> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _step();
    lastPassword = password;
    _passwords[email.trim()] = password;
    if (requiresCode) return SignUpOutcome.codeSent;
    emit(AppUser(id: 'id-$email', email: email.trim(), name: name));
    return SignUpOutcome.signedIn;
  }

  @override
  Future<void> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    await _step();
    _checkCode(code);
    emit(AppUser(id: 'id-$email', email: email));
  }

  @override
  Future<void> resendSignUpCode(String email) => _step();

  @override
  Future<void> requestPasswordReset(String email) => _step();

  @override
  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  }) async {
    await _step();
    _checkCode(code);
    emit(AppUser(id: 'id-$email', email: email));
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _step();
    lastPassword = newPassword;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    await _step();
    emit(null);
  }

  Future<void> _step() async {
    await hold?.future;
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }

  void _checkCode(String code) {
    if (code != validCode) {
      throw const AuthFailure('Código incorrecto o vencido. Pide uno nuevo.');
    }
  }
}
