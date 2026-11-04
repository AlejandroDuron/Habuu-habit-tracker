// perfil guardado en memoria, sin red

import 'dart:async';

import 'package:habuu/data/datasources/profile_data_source.dart';
import 'package:habuu/data/models/user_profile.dart';

class FakeProfileDataSource implements ProfileDataSource {
  FakeProfileDataSource({UserProfile? profile})
    : stored =
          profile ??
          const UserProfile(
            id: 'user-1',
            email: 'ana@correo.com',
            fullName: 'Ana',
          );

  UserProfile stored;

  /// Si no es null, la próxima llamada falla con este error.
  ProfileDataException? nextError;

  /// Si no es null, las llamadas esperan a que se complete. Sirve para ver
  /// el estado de carga.
  Completer<void>? hold;

  int saveCalls = 0;

  @override
  Future<UserProfile> getProfile() async {
    await _step();
    return stored;
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    saveCalls++;
    await _step();
    stored = profile;
    return stored;
  }

  Future<void> _step() async {
    await hold?.future;
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }
}
