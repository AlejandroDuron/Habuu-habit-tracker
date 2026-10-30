import 'package:flutter/foundation.dart';

enum AuthStatus { unauthenticated, authenticated }

/// Flujo que está esperando un código de verificación.
enum VerificationFlow { register, passwordRecovery }

/// Estado y acciones de autenticación.
///
/// Por ahora el "backend" está simulado (espera 700 ms y responde bien).
/// Cuando exista el backend real, reemplaza el contenido de las acciones
/// marcadas con TODO; las pantallas no necesitan cambiar.
class AuthProvider extends ChangeNotifier {
  static const _fakeLatency = Duration(milliseconds: 700);

  AuthStatus _status = AuthStatus.unauthenticated;
  VerificationFlow? _flow;
  bool _isLoading = false;
  bool _codeVerified = false;
  String? _errorMessage;
  String? _userName;
  String? _userEmail;
  String? _pendingName;
  String? _pendingEmail;

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  /// Correo al que se envió el código (registro o recuperación).
  String? get pendingEmail => _pendingEmail;

  Future<bool> login({required String email, required String password}) {
    return _run(() async {
      // TODO: autenticar con el backend.
      await _simulateNetwork();
      _setUser(name: _nameFromEmail(email), email: email.trim());
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() async {
      // TODO: crear la cuenta en el backend y enviar el código por correo.
      await _simulateNetwork();
      _flow = VerificationFlow.register;
      _pendingName = name.trim();
      _pendingEmail = email.trim();
    });
  }

  Future<bool> requestPasswordReset(String email) {
    return _run(() async {
      // TODO: pedir al backend que envíe el código de recuperación.
      await _simulateNetwork();
      _flow = VerificationFlow.passwordRecovery;
      _pendingEmail = email.trim();
      _codeVerified = false;
    });
  }

  Future<bool> verifyCode(String code) {
    return _run(() async {
      await _simulateNetwork();
      switch (_flow) {
        case VerificationFlow.register:
          _setUser(name: _pendingName ?? '', email: _pendingEmail ?? '');
          _clearPending();
        case VerificationFlow.passwordRecovery:
          _codeVerified = true;
        case null:
          throw StateError('No hay una verificación en curso.');
      }
    });
  }

  Future<bool> resendCode() {
    return _run(() async {
      await _simulateNetwork();
    });
  }

  Future<bool> changePassword(String newPassword) {
    return _run(() async {
      await _simulateNetwork();
      if (!_codeVerified) {
        throw StateError('Primero verifica el código.');
      }
      _clearPending();
    });
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    _userName = null;
    _userEmail = null;
    _clearPending();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (e) {
      debugPrint('AuthProvider error: $e');
      _errorMessage = 'Algo salió mal. Inténtalo de nuevo.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _simulateNetwork() => Future<void>.delayed(_fakeLatency);

  void _setUser({required String name, required String email}) {
    _userName = name;
    _userEmail = email;
    _status = AuthStatus.authenticated;
  }

  void _clearPending() {
    _flow = null;
    _codeVerified = false;
    _pendingName = null;
    _pendingEmail = null;
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return '';
    return local[0].toUpperCase() + local.substring(1);
  }
}
