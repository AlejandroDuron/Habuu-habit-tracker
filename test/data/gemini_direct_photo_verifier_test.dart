// pruebas del verificador que llama a Gemini directo, con un cliente http
// falso y una clave inventada

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/datasources/gemini_direct_photo_verifier.dart';
import 'package:habuu/data/datasources/habit_photo_verifier.dart';
import 'package:habuu/data/models/home_habit.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../fakes/fake_evidence_data_source.dart';

const _path = 'user-1/habit-1/2026-11-02.jpg';
const _fakeKey = 'clave-de-prueba';
final _photo = Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0, 1, 2, 3]);

final _habit = HomeHabit(
  id: 'habit-1',
  name: 'Leer',
  iconKey: 'book',
  type: HomeHabitType.recurring,
  createdDate: DateTime(2026, 11, 1),
);

/// Respuesta de Gemini con [result] como texto, como llega con salida JSON.
http.Response _gemini(Map<String, dynamic> result) => http.Response(
  jsonEncode({
    'candidates': [
      {
        'content': {
          'parts': [
            {'text': jsonEncode(result)},
          ],
        },
      },
    ],
  }),
  200,
);

Matcher _throwsFailure(VerificationFailure failure) => throwsA(
  isA<VerificationException>().having((e) => e.failure, 'failure', failure),
);

void main() {
  late FakeEvidenceDataSource evidence;

  setUp(() {
    evidence = FakeEvidenceDataSource()..photos[_path] = _photo;
  });

  GeminiDirectPhotoVerifier build(
    MockClientHandler handler, {
    String apiKey = _fakeKey,
    Duration timeout = const Duration(seconds: 5),
  }) {
    return GeminiDirectPhotoVerifier(
      evidence,
      client: MockClient(handler),
      apiKey: apiKey,
      model: 'modelo-de-prueba',
      timeout: timeout,
    );
  }

  test('arma bien la petición y lee el resultado', () async {
    late http.Request sent;
    final verifier = build((request) async {
      sent = request;
      return _gemini({
        'coincide': true,
        'confianza': 0.8,
        'motivo': 'Se ve un libro.',
      });
    });

    final result = await verifier.verify(photoPath: _path, habit: _habit);

    expect(
      sent.url.toString(),
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'modelo-de-prueba:generateContent',
    );
    // La clave va en el header, nunca en la URL.
    expect(sent.headers['x-goog-api-key'], _fakeKey);
    expect(sent.url.toString(), isNot(contains(_fakeKey)));

    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    final parts = body['contents'][0]['parts'] as List;
    expect(parts[0]['text'], contains('"Leer"'));
    expect(parts[1]['inline_data'], {
      'mime_type': 'image/jpeg',
      'data': base64Encode(_photo),
    });
    expect(body['generationConfig']['responseMimeType'], 'application/json');
    expect(body['generationConfig']['responseJsonSchema'], isNotNull);

    expect(result.coincide, isTrue);
    expect(result.motivo, 'Se ve un libro.');
  });

  test('sin clave falla con un error claro y no llama a Gemini', () async {
    var calls = 0;
    final verifier = build((_) async {
      calls++;
      return http.Response('', 200);
    }, apiKey: '');

    await expectLater(
      verifier.verify(photoPath: _path, habit: _habit),
      _throwsFailure(VerificationFailure.sinClave),
    );
    expect(calls, 0);
  });

  group('errores de Gemini', () {
    final cases = {
      429: VerificationFailure.cuotaAgotada,
      403: VerificationFailure.sinClave,
      500: VerificationFailure.servidor,
      503: VerificationFailure.servidor,
    };

    cases.forEach((status, failure) {
      test('$status → ${failure.name}', () {
        final verifier = build((_) async => http.Response('{}', status));

        expect(
          verifier.verify(photoPath: _path, habit: _habit),
          _throwsFailure(failure),
        );
      });
    });
  });

  test('sin conexión', () {
    final verifier = build(
      (_) async => throw http.ClientException('Failed host lookup'),
    );

    expect(
      verifier.verify(photoPath: _path, habit: _habit),
      _throwsFailure(VerificationFailure.sinConexion),
    );
  });

  test('Gemini tarda más que el timeout', () {
    final verifier = build((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return _gemini({'coincide': true, 'confianza': 1, 'motivo': 'Ok.'});
    }, timeout: const Duration(milliseconds: 20));

    expect(
      verifier.verify(photoPath: _path, habit: _habit),
      _throwsFailure(VerificationFailure.timeout),
    );
  });

  test('Gemini responde 200 con JSON mal formado', () {
    final verifier = build((_) async => http.Response('{"candidates": [', 200));

    expect(
      verifier.verify(photoPath: _path, habit: _habit),
      _throwsFailure(VerificationFailure.respuestaInvalida),
    );
  });

  test('la foto no existe en Storage', () {
    evidence.photos.clear();
    final verifier = build((_) async => http.Response('', 200));

    expect(
      verifier.verify(photoPath: _path, habit: _habit),
      _throwsFailure(VerificationFailure.fotoNoValida),
    );
  });

  test('no se pudo descargar la foto por falta de conexión', () {
    evidence.errorToThrow = http.ClientException('Failed host lookup');
    final verifier = build((_) async => http.Response('', 200));

    expect(
      verifier.verify(photoPath: _path, habit: _habit),
      _throwsFailure(VerificationFailure.sinConexion),
    );
  });
}
