import '../models/user_profile.dart';

abstract interface class ProfileDataSource {
  /// Perfil del usuario con sesión iniciada.
  Future<UserProfile> getProfile();

  /// Guarda todos los campos de [profile] y devuelve cómo quedó guardado.
  Future<UserProfile> saveProfile(UserProfile profile);
}

/// Error al leer o guardar el perfil, con un mensaje listo para mostrarse.
class ProfileDataException implements Exception {
  const ProfileDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
