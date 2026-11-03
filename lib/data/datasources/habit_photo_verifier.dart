import '../models/home_habit.dart';
import '../models/verification_result.dart';

/// Revisa si una foto de evidencia tiene que ver con su hábito.
abstract interface class HabitPhotoVerifier {
  /// [photoPath] es la ruta de la foto dentro del bucket de evidencias, la
  /// misma que devuelve la subida.
  ///
  /// Lanza [VerificationException] si no se pudo verificar.
  Future<VerificationResult> verify({
    required String photoPath,
    required HomeHabit habit,
  });
}

/// Por qué no se pudo verificar una foto, con el mensaje que ve el usuario.
enum VerificationFailure {
  sinConexion('Sin conexión. No se pudo verificar la foto.'),
  timeout('La verificación tardó demasiado. Inténtalo de nuevo.'),
  cuotaAgotada(
    'Se alcanzó el límite de verificaciones por ahora. Inténtalo más tarde.',
  ),
  servidor('El servicio de verificación falló. Inténtalo más tarde.'),
  respuestaInvalida('No se entendió la respuesta del verificador.'),
  fotoNoValida('No se pudo verificar esta foto. Prueba con otra.'),
  sinClave('Falta configurar la clave de Gemini para verificar fotos.');

  const VerificationFailure(this.message);

  final String message;
}

/// Error al verificar, con un mensaje listo para mostrarse.
class VerificationException implements Exception {
  const VerificationException(this.failure);

  final VerificationFailure failure;

  String get message => failure.message;

  @override
  String toString() => message;
}
