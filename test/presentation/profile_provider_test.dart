import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/datasources/profile_data_source.dart';
import 'package:habuu/data/models/user_profile.dart';
import 'package:habuu/data/repositories/profile_repository.dart';
import 'package:habuu/presentation/providers/profile_provider.dart';

import '../fakes/fake_profile_data_source.dart';

void main() {
  late FakeProfileDataSource profiles;
  late ProfileProvider provider;

  setUp(() {
    profiles = FakeProfileDataSource();
    provider = ProfileProvider(ProfileRepository(profiles));
  });

  group('load', () {
    test('pasa por loading y termina en ready con el perfil', () async {
      profiles.hold = Completer<void>();
      final loading = provider.load();
      expect(provider.status, ProfileStatus.loading);

      profiles.hold!.complete();
      await loading;

      expect(provider.status, ProfileStatus.ready);
      expect(provider.profile?.fullName, 'Ana');
    });

    test('si falla, queda en error con el mensaje de la fuente', () async {
      profiles.nextError = const ProfileDataException('Sin conexión');

      await provider.load();

      expect(provider.status, ProfileStatus.error);
      expect(provider.errorMessage, 'Sin conexión');
      expect(provider.profile, isNull);
    });
  });

  group('save', () {
    setUp(() => provider.load());

    test('guarda y actualiza el perfil en memoria', () async {
      final updated = UserProfile(
        id: 'user-1',
        email: 'ana@correo.com',
        fullName: 'Ana María',
        gender: Gender.female,
        birthday: DateTime(2002, 5, 12),
      );

      final ok = await provider.save(updated);

      expect(ok, isTrue);
      expect(provider.profile, updated);
      expect(profiles.stored, updated);
      expect(provider.isSaving, isFalse);
    });

    test('si falla, devuelve false y el perfil queda como estaba', () async {
      profiles.nextError = const ProfileDataException('No se pudo guardar');
      const updated = UserProfile(
        id: 'user-1',
        email: 'ana@correo.com',
        fullName: 'Otro nombre',
      );

      final ok = await provider.save(updated);

      expect(ok, isFalse);
      expect(provider.errorMessage, 'No se pudo guardar');
      expect(provider.profile?.fullName, 'Ana');
    });

    test('ignora un segundo guardado mientras hay uno en curso', () async {
      profiles.hold = Completer<void>();
      const updated = UserProfile(
        id: 'user-1',
        email: 'ana@correo.com',
        fullName: 'Ana María',
      );

      final first = provider.save(updated);
      expect(provider.isSaving, isTrue);
      expect(await provider.save(updated), isFalse);

      profiles.hold!.complete();
      expect(await first, isTrue);
      expect(profiles.saveCalls, 1);
    });
  });

  test('una llamada que termina después de dispose no lanza error', () async {
    profiles.hold = Completer<void>();
    final loading = provider.load();
    provider.dispose();

    profiles.hold!.complete();
    await loading;
  });
}
