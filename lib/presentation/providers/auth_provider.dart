import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { unauthenticated, authenticated }

/// Flujo que está esperando un código de verificación.
enum VerificationFlow { register, passwordRecovery }

/// Error con un mensaje listo para mostrar al usuario.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Estado y acciones de autenticación, conectado a Supabase Auth.
///
/// - Registro: signUp -> código por correo -> verifyOTP (inicia sesión).
/// - Recuperar contraseña: resetPasswordForEmail -> código -> verifyOTP
///   -> updateUser (nueva contraseña) -> signOut.
/// - La sesión se guarda sola: al reabrir la app el usuario sigue dentro.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _syncUser(_client.auth.currentUser);
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      _syncUser(data.session?.user);
      notifyListeners();
    });
  }

  static const _genericError = 'Algo salió mal. Inténtalo de nuevo.';

  SupabaseClient get _client => Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  AuthStatus _status = AuthStatus.unauthenticated;
  VerificationFlow? _flow;
  bool _isLoading = false;
  bool _codeVerified = false;
  String? _errorMessage;
  String? _userName;
  String? _userEmail;

  /// Correo del flujo en curso. Solo vive en memoria.
  String? _pendingEmail;

  AuthStatus get status => _status;

  /// Hay sesión iniciada. Durante la recuperación de contraseña Supabase abre
  /// una sesión temporal; mientras dure no cuenta como "dentro de la app".
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated &&
      _flow != VerificationFlow.passwordRecovery;

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
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() async {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );

      // Si el correo ya tiene una cuenta verificada, Supabase no da error
      // (para no revelar qué correos existen) pero devuelve un usuario sin
      // identidades y no envía ningún código.
      final identities = response.user?.identities;
      if (identities != null && identities.isEmpty) {
        throw const AuthFailure(
          'Este correo ya está registrado. Inicia sesión.',
        );
      }

      _flow = VerificationFlow.register;
      _pendingEmail = email.trim();
      _codeVerified = false;
    });
  }

  Future<bool> requestPasswordReset(String email) {
    return _run(() async {
      await _client.auth.resetPasswordForEmail(email.trim());
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
          // Confirma la cuenta e inicia sesión.
          await _client.auth.verifyOTP(
            type: OtpType.signup,
            email: email,
            token: code,
          );
          _clearPending();
        case VerificationFlow.passwordRecovery:
          // Abre una sesión temporal que permite cambiar la contraseña.
          await _client.auth.verifyOTP(
            type: OtpType.recovery,
            email: email,
            token: code,
          );
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
          await _client.auth.resend(type: OtpType.signup, email: email);
        case VerificationFlow.passwordRecovery:
          await _client.auth.resetPasswordForEmail(email);
      }
    });
  }

  Future<bool> changePassword(String newPassword) {
    return _run(() async {
      if (!_codeVerified) {
        throw const AuthFailure('Primero verifica el código.');
      }
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      // Cierra la sesión temporal: el usuario inicia sesión con la nueva.
      await _client.auth.signOut();
      _clearPending();
    });
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('AuthProvider logout error: $e');
    }
    _clearPending();
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
    } on AuthException catch (e) {
      debugPrint('AuthProvider AuthException: ${e.message}');
      _errorMessage = _translateAuthException(e);
      return false;
    } catch (e) {
      debugPrint('AuthProvider error: $e');
      _errorMessage = _genericError;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _translateAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('email not confirmed')) {
      return 'Tu cuenta aún no está verificada. Crea la cuenta de nuevo '
          'para recibir otro código.';
    }
    if (message.contains('expired') || message.contains('invalid')) {
      return 'Código incorrecto o vencido. Pide uno nuevo.';
    }
    if (message.contains('rate limit') ||
        message.contains('only request this after')) {
      return 'Espera un momento antes de pedir otro código.';
    }
    if (message.contains('different from the old password')) {
      return 'La nueva contraseña debe ser distinta a la anterior.';
    }
    if (message.contains('password')) {
      return 'La contraseña no cumple los requisitos.';
    }
    return _genericError;
  }

  void _syncUser(User? user) {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userName = null;
      _userEmail = null;
      return;
    }
    _status = AuthStatus.authenticated;
    _userEmail = user.email;
    _userName = (user.userMetadata?['name'] as String?) ??
        _nameFromEmail(user.email ?? '');
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
