import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Guarda la sesión de Supabase (access token y refresh token) cifrada:
/// en el Keychain en iOS y con una clave del Keystore en Android.
/// Supabase por defecto la deja en SharedPreferences, en texto plano.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({
    required this.persistSessionKey,
    // first_unlock: para poder renovar el token con la app en segundo plano
    this._storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  });

  /// Debe ser la misma clave que usa Supabase (`sb-<proyecto>-auth-token`)
  /// para encontrar la sesión que haya quedado en SharedPreferences.
  final String persistSessionKey;
  final FlutterSecureStorage _storage;

  @override
  Future<void> initialize() => _moveFromSharedPreferences();

  @override
  Future<bool> hasAccessToken() async => await accessToken() != null;

  /// null = no hay sesión guardada (o no se pudo leer, que para la app es
  /// lo mismo: pide iniciar sesión).
  @override
  Future<String?> accessToken() async {
    try {
      return await _storage.read(key: persistSessionKey);
    } catch (e) {
      debugPrint('No se pudo leer la sesión guardada: ${e.runtimeType}');
      return null;
    }
  }

  @override
  Future<void> removePersistedSession() =>
      _storage.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: persistSessionKey, value: persistSessionString);

  /// Si hay una sesión en SharedPreferences (donde la pone Supabase por
  /// defecto), se pasa aquí y se borra de allá. Así el usuario no tiene que
  /// volver a iniciar sesión y el token no queda en texto plano.
  Future<void> _moveFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plain = prefs.getString(persistSessionKey);
      if (plain == null) return;

      if (await accessToken() == null) {
        await persistSession(plain);
      }
      await prefs.remove(persistSessionKey);
    } catch (e) {
      debugPrint('No se pudo mover la sesión guardada: ${e.runtimeType}');
    }
  }
}
