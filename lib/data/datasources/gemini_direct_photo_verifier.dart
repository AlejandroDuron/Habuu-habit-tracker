import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/home_habit.dart';
import '../models/verification_result.dart';
import 'evidence_data_source.dart';
import 'gemini_verification_prompt.dart';
import 'habit_photo_verifier.dart';

/// Llama a Gemini directo desde la app. Solo para probar en local: la clave
/// va dentro del APK aunque se pase con --dart-define, así que no se usa en
/// la versión que se entrega.
///
/// `flutter run --dart-define=GEMINI_API_KEY=tu_clave`
class GeminiDirectPhotoVerifier implements HabitPhotoVerifier {
  GeminiDirectPhotoVerifier(
    this._evidence, {
    http.Client? client,
    this.apiKey = const String.fromEnvironment('GEMINI_API_KEY'),
    this.model = defaultGeminiModel,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  final EvidenceDataSource _evidence;
  final http.Client _client;
  final String apiKey;
  final String model;
  final Duration timeout;

  Uri get _endpoint => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/'
    '$model:generateContent',
  );

  @override
  Future<VerificationResult> verify({
    required String photoPath,
    required HomeHabit habit,
  }) async {
    if (apiKey.isEmpty) {
      debugPrint(
        'Falta GEMINI_API_KEY. Corre la app con '
        '--dart-define=GEMINI_API_KEY=tu_clave',
      );
      throw const VerificationException(VerificationFailure.sinClave);
    }

    final photo = await _download(photoPath);

    final http.Response response;
    try {
      response = await _client
          .post(
            _endpoint,
            headers: {
              'Content-Type': 'application/json',
              // En el header para que no aparezca en la URL.
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(_requestBody(habit, photo)),
          )
          .timeout(timeout);
    } on TimeoutException {
      debugPrint('Gemini no respondió a tiempo');
      throw const VerificationException(VerificationFailure.timeout);
    } on http.ClientException {
      debugPrint('No se pudo llegar a Gemini');
      throw const VerificationException(VerificationFailure.sinConexion);
    }

    if (response.statusCode != 200) {
      debugPrint('Gemini respondió ${response.statusCode}');
      throw VerificationException(switch (response.statusCode) {
        429 => VerificationFailure.cuotaAgotada,
        // Clave inválida o sin permiso para ese modelo.
        401 || 403 => VerificationFailure.sinClave,
        _ => VerificationFailure.servidor,
      });
    }

    return parseGeminiResponse(response.body);
  }

  Future<Uint8List> _download(String path) async {
    try {
      return await _evidence.download(path).timeout(timeout);
    } on TimeoutException {
      debugPrint('La foto no se descargó a tiempo');
      throw const VerificationException(VerificationFailure.timeout);
    } on http.ClientException {
      debugPrint('No se pudo descargar la foto, sin conexión');
      throw const VerificationException(VerificationFailure.sinConexion);
    } catch (e) {
      debugPrint('No se pudo descargar la foto: ${e.runtimeType}');
      throw const VerificationException(VerificationFailure.fotoNoValida);
    }
  }

  Map<String, dynamic> _requestBody(HomeHabit habit, Uint8List photo) {
    return {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': buildVerificationPrompt(habit)},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Encode(photo),
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseJsonSchema': verificationResponseSchema,
      },
    };
  }
}
