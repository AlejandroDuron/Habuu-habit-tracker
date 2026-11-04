import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../repositories/auth_error_messages.dart';
import 'profile_data_source.dart';

/// Guarda el perfil en los `user_metadata` de la cuenta. Supabase Auth
/// solo deja que cada usuario cambie los suyos, así que no hace falta
/// tabla ni políticas.
class SupabaseProfileDataSource implements ProfileDataSource {
  SupabaseProfileDataSource(this._auth);

  final GoTrueClient _auth;

  @override
  Future<UserProfile> getProfile() {
    return _request(() async {
      // getUser va al servidor: trae lo último aunque se haya editado
      // desde otro celular.
      final response = await _auth.getUser();
      return _toProfile(response.user);
    });
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) {
    return _request(() async {
      if (profile.id != _auth.currentUser?.id) {
        throw const ProfileDataException('Vuelve a iniciar sesión');
      }
      final response = await _auth.updateUser(
        UserAttributes(data: profile.toMetadata()),
      );
      return _toProfile(response.user);
    });
  }

  UserProfile _toProfile(User? user) {
    if (user == null) {
      throw const ProfileDataException('Vuelve a iniciar sesión');
    }
    return UserProfile.fromMetadata(
      id: user.id,
      email: user.email ?? '',
      metadata: user.userMetadata,
    );
  }

  /// En el log va solo el código del error, nunca los datos del perfil.
  Future<T> _request<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ProfileDataException {
      rethrow;
    } on AuthException catch (e) {
      debugPrint('Auth falló (perfil): code=${e.code} status=${e.statusCode}');
      throw ProfileDataException(authErrorMessage(e));
    } catch (e) {
      debugPrint('Error de conexión (perfil): ${e.runtimeType}');
      throw const ProfileDataException(
        'Revisa tu conexión e inténtalo de nuevo',
      );
    }
  }
}
