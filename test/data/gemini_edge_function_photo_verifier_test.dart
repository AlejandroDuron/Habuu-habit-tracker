// pruebas del verificador que usa la Edge Function, con un cliente http
// falso para no llamar a Supabase de verdad

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/datasources/gemini_edge_function_photo_verifier.dart';
import 'package:habuu/data/datasources/habit_photo_verifier.dart';
import 'package:habuu/data/models/home_habit.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _path = 'user-1/habit-1/2026-11-02.jpg';

HomeHabit _habit({String? goal}) => HomeHabit(
  id: 'habit-1',
  name: 'Leer',
  iconKey: 'book',
  type: HomeHabitType.recurring,
  createdDate: DateTime(2026, 11, 1),
  goal: goal,
);

http.Response _json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

Matcher _throwsFailure(VerificationFailure failure) => throwsA(
  isA<VerificationException>().having((e) => e.failure, 'failure', failure),
);

void main() {
  late FunctionsClient functions;

  /// Arma el verificador con un cliente que responde lo que diga [handler].
  GeminiEdgeFunctionPhotoVerifier build(
    MockClientHandler handler, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    functions = FunctionsClient(
      'https://prueba.supabase.co/functions/v1',
      {},
      httpClient: MockClient(handler),
    );
    return GeminiEdgeFunctionPhotoVerifier(functions, timeout: timeout);
  }

  tearDown(() => functions.dispose());

  test('manda la ruta y los datos del hábito, y lee el resultado', () async {
    late http.Request sent;
    final verifier = build((request) async {
      sent = request;
      return _json({
        'coincide': true,
        'confianza': 0.9,
        'motivo': 'Se ve un libro.',
      }, 200);
    });

    final result = await verifier.verify(
      photoPath: _path,
      habit: _habit(goal: '10 páginas'),
    );

    expect(sent.url.path, endsWith('/verify-habit-photo'));
    expect(jsonDecode(sent.body), {
      'photoPath': _path,
      'habitName': 'Leer',
      'habitGoal': '10 páginas',
    });
    expect(result.coincide, isTrue);
    expect(result.confianza, closeTo(0.9, 0.001));
  });

  test('si el hábito no tiene meta, no la manda', () async {
    late http.Request sent;
    final verifier = build((request) async {
      sent = request;
      return _json({'coincide': false, 'confianza': 0.6, 'motivo': 'No.'}, 200);
    });

    await verifier.verify(photoPath: _path, habit: _habit());

    expect(jsonDecode(sent.body), isNot(contains('habitGoal')));
  });

  group('errores de la función', () {
    final cases = {
      429: VerificationFailure.cuotaAgotada,
      504: VerificationFailure.timeout,
      403: VerificationFailure.fotoNoValida,
      404: VerificationFailure.fotoNoValida,
      413: VerificationFailure.fotoNoValida,
      500: VerificationFailure.servidor,
      401: VerificationFailure.servidor,
    };

    cases.forEach((status, failure) {
      test('$status → ${failure.name}', () {
        final verifier = build(
          (_) async => _json({'error': 'x', 'message': 'x'}, status),
        );

        expect(
          verifier.verify(photoPath: _path, habit: _habit()),
          _throwsFailure(failure),
        );
      });
    });

    test('502 por respuesta inválida de Gemini', () {
      final verifier = build(
        (_) async => _json({
          'error': 'respuesta_invalida',
          'message': 'No se entendió la respuesta de Gemini.',
        }, 502),
      );

      expect(
        verifier.verify(photoPath: _path, habit: _habit()),
        _throwsFailure(VerificationFailure.respuestaInvalida),
      );
    });
  });

  test('sin conexión', () {
    final verifier = build(
      (_) async => throw http.ClientException('Failed host lookup'),
    );

    expect(
      verifier.verify(photoPath: _path, habit: _habit()),
      _throwsFailure(VerificationFailure.sinConexion),
    );
  });

  test('la función tarda más que el timeout', () {
    final verifier = build((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return _json({'coincide': true, 'confianza': 1, 'motivo': 'Ok.'}, 200);
    }, timeout: const Duration(milliseconds: 20));

    expect(
      verifier.verify(photoPath: _path, habit: _habit()),
      _throwsFailure(VerificationFailure.timeout),
    );
  });

  test('200 pero con confianza fuera de rango', () {
    final verifier = build(
      (_) async =>
          _json({'coincide': true, 'confianza': 7, 'motivo': 'Ok.'}, 200),
    );

    expect(
      verifier.verify(photoPath: _path, habit: _habit()),
      _throwsFailure(VerificationFailure.respuestaInvalida),
    );
  });

  test('200 con JSON mal formado', () {
    final verifier = build(
      (_) async => http.Response(
        '{"coincide": tr',
        200,
        headers: {'content-type': 'application/json'},
      ),
    );

    expect(
      verifier.verify(photoPath: _path, habit: _habit()),
      _throwsFailure(VerificationFailure.respuestaInvalida),
    );
  });

  test('200 pero con texto en lugar de JSON', () {
    final verifier = build((_) async => http.Response('ok', 200));

    expect(
      verifier.verify(photoPath: _path, habit: _habit()),
      _throwsFailure(VerificationFailure.respuestaInvalida),
    );
  });
}
