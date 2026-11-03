import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'auth_error_messages.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._auth);

  final GoTrueClient _auth;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.onAuthStateChange.map((state) => _toAppUser(state.session?.user));

  @override
  Future<void> signIn({required String email, required String password}) {
    return _guard(
      () => _auth.signInWithPassword(email: email.trim(), password: password),
    );
  }

  @override
  Future<SignUpOutcome> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );

      // Si el correo ya tiene una cuenta verificada, Supabase no da error
      // (para no revelar qué correos existen) pero devuelve un usuario sin
      // identidades y no envía ningún código.
      final identities = response.user?.identities;
      if (identities != null && identities.isEmpty) {
        throw const AuthFailure(emailTakenAuthError);
      }

      return response.session == null
          ? SignUpOutcome.codeSent
          : SignUpOutcome.signedIn;
    });
  }

  @override
  Future<void> verifySignUpCode({required String email, required String code}) {
    return _guard(
      () => _auth.verifyOTP(type: OtpType.signup, email: email, token: code),
    );
  }

  @override
  Future<void> resendSignUpCode(String email) {
    return _guard(() => _auth.resend(type: OtpType.signup, email: email));
  }

  @override
  Future<void> requestPasswordReset(String email) {
    return _guard(() => _auth.resetPasswordForEmail(email.trim()));
  }

  @override
  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  }) {
    return _guard(
      () => _auth.verifyOTP(type: OtpType.recovery, email: email, token: code),
    );
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return _guard(
      () => _auth.updateUser(UserAttributes(password: newPassword)),
    );
  }

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  /// Convierte los errores de Supabase en [AuthFailure]. En el log va solo el
  /// código, nunca el correo.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      debugPrint(
        'Auth falló: ${e.runtimeType} code=${e.code} status=${e.statusCode}',
      );
      throw AuthFailure(authErrorMessage(e));
    }
  }

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
    );
  }
}
