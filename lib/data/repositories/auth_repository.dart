import '../models/app_user.dart';

/// Error de autenticación con un mensaje listo para mostrar al usuario.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Cómo terminó el registro.
enum SignUpOutcome {
  /// Hay que confirmar el correo con el código que se envió.
  codeSent,

  /// La cuenta quedó lista y con la sesión iniciada (confirmación desactivada).
  signedIn,
}

/// Todo lo que la app puede hacer con las cuentas. Los errores salen como
/// [AuthFailure].
abstract interface class AuthRepository {
  AppUser? get currentUser;

  /// Al escucharlo emite el usuario actual y después cada cambio de sesión.
  /// null = sin sesión.
  Stream<AppUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  Future<SignUpOutcome> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Confirma la cuenta con el código del correo e inicia sesión.
  Future<void> verifySignUpCode({required String email, required String code});

  Future<void> resendSignUpCode(String email);

  Future<void> requestPasswordReset(String email);

  /// Abre una sesión temporal que solo sirve para cambiar la contraseña.
  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  });

  Future<void> updatePassword(String newPassword);

  Future<void> signOut();
}
