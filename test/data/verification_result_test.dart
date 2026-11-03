// pruebas del modelo VerificationResult, sobre todo que valide lo que llega

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/verification_result.dart';

void main() {
  group('fromJson', () {
    test('lee una respuesta válida', () {
      final result = VerificationResult.fromJson({
        'coincide': true,
        'confianza': 0.87,
        'motivo': '  Se ve un vaso con agua.  ',
      });

      expect(result.coincide, isTrue);
      expect(result.confianza, closeTo(0.87, 0.001));
      expect(result.motivo, 'Se ve un vaso con agua.');
    });

    test('acepta confianza entera (0 o 1)', () {
      final result = VerificationResult.fromJson({
        'coincide': false,
        'confianza': 1,
        'motivo': 'No tiene relación.',
      });

      expect(result.confianza, 1.0);
    });

    test('falla si falta cualquier campo', () {
      final complete = {'coincide': true, 'confianza': 0.5, 'motivo': 'Ok.'};

      for (final key in complete.keys) {
        final json = {...complete}..remove(key);
        expect(
          () => VerificationResult.fromJson(json),
          throwsFormatException,
          reason: 'sin "$key"',
        );
      }
    });

    test('falla si un campo tiene otro tipo', () {
      expect(
        () => VerificationResult.fromJson({
          'coincide': 'true',
          'confianza': 0.5,
          'motivo': 'Ok.',
        }),
        throwsFormatException,
      );
      expect(
        () => VerificationResult.fromJson({
          'coincide': true,
          'confianza': '0.5',
          'motivo': 'Ok.',
        }),
        throwsFormatException,
      );
    });

    test('falla si el motivo viene vacío', () {
      expect(
        () => VerificationResult.fromJson({
          'coincide': true,
          'confianza': 0.5,
          'motivo': '   ',
        }),
        throwsFormatException,
      );
    });

    test('falla si la confianza está fuera de 0 a 1', () {
      for (final value in [-0.1, 1.01, 85, double.nan]) {
        expect(
          () => VerificationResult.fromJson({
            'coincide': true,
            'confianza': value,
            'motivo': 'Ok.',
          }),
          throwsFormatException,
          reason: 'confianza = $value',
        );
      }
    });
  });

  test('toJson y fromJson van y vuelven sin perder datos', () {
    final original = VerificationResult(
      coincide: false,
      confianza: 0.3,
      motivo: 'No se ve el hábito.',
    );

    final copy = VerificationResult.fromJson(original.toJson());

    expect(copy.coincide, original.coincide);
    expect(copy.confianza, closeTo(original.confianza, 0.001));
    expect(copy.motivo, original.motivo);
  });

  group('Asserts del constructor', () {
    // Los assert solo corren en modo debug, que es como corren las pruebas.
    test('no deja una confianza fuera de rango', () {
      expect(
        () => VerificationResult(coincide: true, confianza: 2, motivo: 'Ok.'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('no deja un motivo vacío', () {
      expect(
        () => VerificationResult(coincide: true, confianza: 0.5, motivo: ''),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
