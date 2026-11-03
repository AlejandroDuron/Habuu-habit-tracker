import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/home_habit.dart';
import '../models/verification_result.dart';
import 'habit_photo_verifier.dart';

/// Verifica la foto con la Edge Function "verify-habit-photo". La clave de
/// Gemini se queda en Supabase, la app nunca la ve.
class GeminiEdgeFunctionPhotoVerifier implements HabitPhotoVerifier {
  GeminiEdgeFunctionPhotoVerifier(
    this._functions, {
    this.timeout = const Duration(seconds: 45),
  });

  final FunctionsClient _functions;

  /// La función le da 25 s a Gemini, pero antes puede tardar en arrancar
  /// (la primera llamada después de un rato) y en bajar la foto. Si la app
  /// se rinde antes que la función, el usuario ve "se agotó el tiempo"
  /// aunque Gemini sí iba a responder.
  final Duration timeout;

  static const functionName = 'verify-habit-photo';

  @override
  Future<VerificationResult> verify({
    required String photoPath,
    required HomeHabit habit,
  }) async {
    final goal = habit.goal?.trim();

    try {
      final response = await _functions
          .invoke(
            functionName,
            body: {
              'photoPath': photoPath,
              'habitName': habit.name,
              if (goal != null && goal.isNotEmpty) 'habitGoal': goal,
            },
          )
          .timeout(timeout);

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        debugPrint('$functionName respondió algo que no es un objeto JSON');
        throw const VerificationException(
          VerificationFailure.respuestaInvalida,
        );
      }
      return VerificationResult.fromJson(data);
    } on VerificationException {
      rethrow;
    } on TimeoutException {
      debugPrint('$functionName no respondió a tiempo');
      throw const VerificationException(VerificationFailure.timeout);
    } on FunctionsFetchException {
      debugPrint('No se pudo llegar a $functionName');
      throw const VerificationException(VerificationFailure.sinConexion);
    } on FunctionException catch (e) {
      debugPrint('$functionName respondió ${e.status} (${_errorCode(e)})');
      throw VerificationException(_failureFor(e));
    } on FormatException catch (e) {
      debugPrint('$functionName devolvió datos que no sirven: ${e.message}');
      throw const VerificationException(VerificationFailure.respuestaInvalida);
    }
  }

  /// El código que manda la función en { error, message }, si vino.
  static String? _errorCode(FunctionException e) {
    final details = e.details;
    return details is Map ? details['error'] as String? : null;
  }

  static VerificationFailure _failureFor(FunctionException e) {
    return switch (e.status) {
      429 => VerificationFailure.cuotaAgotada,
      504 => VerificationFailure.timeout,
      400 || 403 || 404 || 413 || 415 => VerificationFailure.fotoNoValida,
      _ when _errorCode(e) == 'respuesta_invalida' =>
        VerificationFailure.respuestaInvalida,
      _ => VerificationFailure.servidor,
    };
  }
}
