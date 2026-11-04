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

  group('fullName', () {
    test('vacío o solo espacios pide el nombre', () {
      expect(Validators.fullName(null), 'Ingresa tu nombre');
      expect(Validators.fullName('   '), 'Ingresa tu nombre');
    });

    test('más de 80 caracteres no pasa', () {
      expect(Validators.fullName('a' * 80), isNull);
      expect(
        Validators.fullName('a' * 81),
        'El nombre puede tener hasta 80 caracteres',
      );
    });
  });

  group('phone', () {
    test('es opcional', () {
      expect(Validators.phone(null), isNull);
      expect(Validators.phone('  '), isNull);
    });

    test('acepta espacios, guiones y un + al inicio', () {
      expect(Validators.phone('+503 7123-4567'), isNull);
      expect(Validators.phone('71234567'), isNull);
    });

    test('letras o un + en medio no pasan', () {
      const message = 'Usa solo números, espacios, guiones y un + al inicio';
      expect(Validators.phone('7123abcd'), message);
      expect(Validators.phone('503+71234567'), message);
    });

    test('pide entre 8 y 15 dígitos', () {
      const message = 'El teléfono debe tener entre 8 y 15 dígitos';
      expect(Validators.phone('7123 456'), message);
      expect(Validators.phone('1234567890123456'), message);
      expect(Validators.phone('123456789012345'), isNull);
    });
  });

  group('birthday', () {
    final today = DateTime(2026, 11, 3);

    test('es opcional', () {
      expect(Validators.birthday(null, today: today), isNull);
    });

    test('hoy sí, mañana no', () {
      expect(Validators.birthday(DateTime(2026, 11, 3), today: today), isNull);
      expect(
        Validators.birthday(DateTime(2026, 11, 4), today: today),
        'La fecha no puede ser en el futuro',
      );
    });

    test('antes de 1900 no es válida', () {
      expect(
        Validators.birthday(DateTime(1899, 12, 31), today: today),
        'Ingresa una fecha válida',
      );
    });
  });
}
