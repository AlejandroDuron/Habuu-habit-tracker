// validadores de los formularios de login y registro

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/utils/validators.dart';

void main() {
  group('email', () {
    test('vacío o con espacios pide el correo', () {
      expect(Validators.email(null), 'Ingresa tu correo electrónico');
      expect(Validators.email('   '), 'Ingresa tu correo electrónico');
    });

    test('sin @ o sin dominio no es válido', () {
      expect(Validators.email('ana'), 'Ingresa un correo válido');
      expect(Validators.email('ana@correo'), 'Ingresa un correo válido');
      expect(Validators.email('ana @correo.com'), 'Ingresa un correo válido');
    });

    test('un correo normal pasa, aunque tenga espacios alrededor', () {
      expect(Validators.email('ana@correo.com'), isNull);
      expect(Validators.email('  ana@correo.com '), isNull);
    });
  });

  group('loginPassword', () {
    test('vacía pide la contraseña', () {
      expect(Validators.loginPassword(''), 'Ingresa tu contraseña');
    });

    test('más corta que el mínimo da error', () {
      expect(Validators.loginPassword('1234567'), isNotNull);
    });

    test('no exige mayúsculas ni símbolos', () {
      expect(Validators.loginPassword('abcdefgh'), isNull);
    });
  });

  group('password (registro)', () {
    test('le falta mayúscula, número o símbolo', () {
      expect(Validators.password('abcdefg1!'), isNotNull);
      expect(Validators.password('Abcdefgh!'), isNotNull);
      expect(Validators.password('Abcdefgh1'), isNotNull);
    });

    test('muy corta aunque cumpla lo demás', () {
      expect(Validators.password('Ab1!'), isNotNull);
    });

    test('cumple todo', () {
      expect(Validators.password('Habuu2026!'), isNull);
    });
  });

  group('confirmPassword', () {
    late TextEditingController original;
    late String? Function(String?) validator;

    setUp(() {
      original = TextEditingController(text: 'Habuu2026!');
      validator = Validators.confirmPassword(original);
    });

    tearDown(() => original.dispose());

    test('vacía pide confirmarla', () {
      expect(validator(''), 'Confirma tu contraseña');
    });

    test('distinta a la original', () {
      expect(validator('Habuu2026?'), 'Las contraseñas no coinciden');
    });

    test('igual a la original', () {
      expect(validator('Habuu2026!'), isNull);
    });

    test('lee el texto actual del otro campo, no el de cuando se creó', () {
      original.text = 'OtraClave1!';
      expect(validator('Habuu2026!'), 'Las contraseñas no coinciden');
      expect(validator('OtraClave1!'), isNull);
    });
  });
}
