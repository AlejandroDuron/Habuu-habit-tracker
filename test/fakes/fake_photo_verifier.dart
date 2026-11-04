// verificador que responde lo que le digamos, sin internet ni Gemini, para
// probar la pantalla en cada estado

import 'package:habuu/data/datasources/habit_photo_verifier.dart';
import 'package:habuu/data/models/home_habit.dart';
import 'package:habuu/data/models/verification_result.dart';

class FakePhotoVerifier implements HabitPhotoVerifier {
  FakePhotoVerifier({
    VerificationResult? result,
    this.failure,
    this.failuresLeft,
    this.delay = Duration.zero,
  }) : result = result ?? matching();

  /// Lo que se devuelve cuando no hay [failure].
  VerificationResult result;

  /// Si no es null, se lanza esta falla en lugar de devolver [result].
  VerificationFailure? failure;

  /// Cuántas veces más se lanza [failure] antes de responder bien.
  /// null = siempre falla.
  int? failuresLeft;

  /// Cuánto tarda en responder, para ver el estado "verificando".
  Duration delay;

  /// Rutas que se pidieron verificar, en orden.
  final List<String> verifiedPaths = [];

  @override
  Future<VerificationResult> verify({
    required String photoPath,
    required HomeHabit habit,
  }) async {
    verifiedPaths.add(photoPath);
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    final failure = this.failure;
    final left = failuresLeft;
    if (failure != null && (left == null || left > 0)) {
      if (left != null) failuresLeft = left - 1;
      throw VerificationException(failure);
    }
    return result;
  }

  static VerificationResult matching() => VerificationResult(
    coincide: true,
    confianza: 0.92,
    motivo: 'Se ve un libro abierto.',
  );

  static VerificationResult notMatching() => VerificationResult(
    coincide: false,
    confianza: 0.85,
    motivo: 'La foto muestra una calle, no un libro.',
  );
}
