import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_error_messages.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, authenticated }

/// Flujo que está esperando un código de verificación.
enum VerificationFlow { register, passwordRecovery }

/// Estado y acciones de autenticación para las pantallas.
///
/// - Registro: signUp -> código por correo -> verifyOTP (inicia sesión).
/// - Recuperar contraseña: resetPasswordForEmail -> código -> verifyOTP
///   -> updateUser (nueva contraseña) -> signOut.
/// - La sesión se guarda sola: al reabrir la app el usuario sigue dentro.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository) {
    _syncUser(_repository.currentUser);
    _authSubscription = _repository.authStateChanges().listen((user) {
      _syncUser(user);
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;

  AuthStatus _status = AuthStatus.unauthenticated;
  VerificationFlow? _flow;
  bool _isLoading = false;
  bool _codeVerified = false;
  bool _showWelcome = false;
  String? _errorMessage;
  String? _userId;
  String? _userName;
  String? _userEmail;

  /// Correo del flujo en curso. Solo vive en memoria.
  String? _pendingEmail;

  AuthStatus get status => _status;

  /// Hay sesión iniciada. Durante la recuperación de contraseña Supabase abre
  /// una sesión temporal; mientras dure no cuenta como "dentro de la app".
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && !isRecoveringPassword;

  bool get isRecoveringPassword => _flow == VerificationFlow.passwordRecovery;

  /// El registro mandó un código y falta ingresarlo.
  bool get isWaitingForCode => _flow == VerificationFlow.register;

  /// Cuenta recién creada: antes del home van "Cuenta verificada" y el
  /// onboarding.
  bool get showWelcome => _showWelcome;

  /// Id del usuario dentro de la app, o null si no ha entrado.
  String? get userId => isAuthenticated ? _userId : null;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  /// Correo al que se envió el código (registro o recuperación).
  String? get pendingEmail => _pendingEmail;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() async {
      // Si quedó una recuperación a medias, no debe bloquear la entrada.
      _clearPending();
      _showWelcome = false;
      await _repository.signIn(email: email, password: password);
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() async {
      _clearPending();
      final outcome = await _welcomeAfter(
        () => _repository.signUp(name: name, email: email, password: password),
      );
      if (outcome == SignUpOutcome.codeSent) {
        _showWelcome = false;
        _flow = VerificationFlow.register;
        _pendingEmail = email.trim();
      }
    });
  }

  Future<bool> requestPasswordReset(String email) {
    return _run(() async {
      await _repository.requestPasswordReset(email);
      _flow = VerificationFlow.passwordRecovery;
      _pendingEmail = email.trim();
      _codeVerified = false;
    });
  }

  /// Verifica el código del flujo activo (registro o recuperación).
  Future<bool> verifyCode(String code) {
    return _run(() async {
      final email = _pendingEmail;
      final flow = _flow;
      if (email == null || flow == null) {
        throw const AuthFailure('Vuelve a empezar el proceso.');
      }

      switch (flow) {
        case VerificationFlow.register:
          await _welcomeAfter(
            () => _repository.verifySignUpCode(email: email, code: code),
          );
          _clearPending();
        case VerificationFlow.passwordRecovery:
          await _repository.verifyRecoveryCode(email: email, code: code);
          _codeVerified = true;
      }
    });
  }

  Future<bool> resendCode() {
    return _run(() async {
      final email = _pendingEmail;
      final flow = _flow;
      if (email == null || flow == null) {
        throw const AuthFailure('Vuelve a empezar el proceso.');
      }

      switch (flow) {
        case VerificationFlow.register:
          await _repository.resendSignUpCode(email);
        case VerificationFlow.passwordRecovery:
          await _repository.requestPasswordReset(email);
      }
    });
  }

  Future<bool> changePassword(String newPassword) {
    return _run(() async {
      if (!_codeVerified) {
        throw const AuthFailure('Primero verifica el código.');
      }
      await _repository.updatePassword(newPassword);
      // Cierra la sesión temporal: el usuario inicia sesión con la nueva.
      await _repository.signOut();
      _clearPending();
    });
  }

  Future<void> logout() async {
    try {
      await _repository.signOut();
    } catch (e) {
      debugPrint('AuthProvider logout error: $e');
    }
    _clearPending();
    _showWelcome = false;
    notifyListeners();
  }

  void finishWelcome() {
    if (!_showWelcome) return;
    _showWelcome = false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Ejecuta una acción con estado de carga y manejo de errores.
  /// Devuelve true si terminó bien. Ignora llamadas mientras hay una en curso.
  Future<bool> _run(Future<void> Function() action) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      debugPrint('AuthProvider error: $e');
      _errorMessage = genericAuthError;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deja [showWelcome] encendido mientras corre [action], porque la sesión
  /// nueva puede emitirse antes de que la llamada termine. Si falla, lo apaga.
  Future<T> _welcomeAfter<T>(Future<T> Function() action) async {
    _showWelcome = true;
    try {
      return await action();
    } catch (_) {
      _showWelcome = false;
      rethrow;
    }
  }

  void _syncUser(AppUser? user) {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userId = null;
      _userName = null;
      _userEmail = null;
      return;
    }
    _status = AuthStatus.authenticated;
    _userId = user.id;
    _userEmail = user.email;
    _userName = user.name ?? _nameFromEmail(user.email);
  }

  void _clearPending() {
    _flow = null;
    _codeVerified = false;
    _pendingEmail = null;
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return '';
    return local[0].toUpperCase() + local.substring(1);
  }
}
