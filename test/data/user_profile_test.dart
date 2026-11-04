// conversión del perfil desde y hacia los user_metadata de la cuenta

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/user_profile.dart';

void main() {
  UserProfile fromMetadata(Map<String, dynamic>? metadata) =>
      UserProfile.fromMetadata(
        id: 'u1',
        email: 'ana@correo.com',
        metadata: metadata,
      );

  group('UserProfile.fromMetadata', () {
    test('lee todas las claves', () {
      final profile = fromMetadata({
        'name': 'Ana López',
        'phone': '+503 7123 4567',
        'gender': 'female',
        'birthday': '2002-05-12',
      });

      expect(profile.id, 'u1');
      expect(profile.email, 'ana@correo.com');
      expect(profile.fullName, 'Ana López');
      expect(profile.phone, '+503 7123 4567');
      expect(profile.gender, Gender.female);
      expect(profile.birthday, DateTime(2002, 5, 12));
    });

    test('una cuenta recién registrada solo tiene el nombre', () {
      final profile = fromMetadata({'name': 'Ana'});

      expect(profile.fullName, 'Ana');
      expect(profile.phone, isNull);
      expect(profile.gender, isNull);
      expect(profile.birthday, isNull);
    });

    test('sin metadatos queda todo vacío', () {
      final profile = fromMetadata(null);

      expect(profile.fullName, '');
      expect(profile.phone, isNull);
    });

    test('valores de otro tipo o que no se reconocen se ignoran', () {
      final profile = fromMetadata({
        'name': 42,
        'phone': '   ',
        'gender': 'desconocido',
        'birthday': 'ayer',
      });

      expect(profile.fullName, '');
      expect(profile.phone, isNull);
      expect(profile.gender, isNull);
      expect(profile.birthday, isNull);
    });
  });

  group('UserProfile.toMetadata', () {
    test('usa las claves del registro y la fecha sin hora', () {
      final metadata = UserProfile(
        id: 'u1',
        email: 'ana@correo.com',
        fullName: 'Ana',
        phone: '7123 4567',
        gender: Gender.preferNotSay,
        birthday: DateTime(2002, 5, 2, 18, 30),
      ).toMetadata();

      expect(metadata, {
        'name': 'Ana',
        'phone': '7123 4567',
        'gender': 'prefer_not_say',
        'birthday': '2002-05-02',
      });
    });

    test('no incluye el id ni el correo', () {
      final metadata = const UserProfile(
        id: 'u1',
        email: 'ana@correo.com',
      ).toMetadata();

      expect(metadata.containsKey('id'), isFalse);
      expect(metadata.containsKey('email'), isFalse);
    });

    test('ida y vuelta da el mismo perfil', () {
      final original = UserProfile(
        id: 'u1',
        email: 'ana@correo.com',
        fullName: 'Ana',
        phone: '71234567',
        gender: Gender.other,
        birthday: DateTime(1999, 12, 31),
      );

      expect(fromMetadata(original.toMetadata()), original);
    });
  });
}
