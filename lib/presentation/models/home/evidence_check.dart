import 'dart:typed_data';

import '../../../data/models/verification_result.dart';

/// En qué va la revisión de una foto.
enum VerificationStatus { verificando, verificado, noConfirmado, noSePudo }

/// Una foto subida que se está revisando, o que ya se revisó.
class EvidenceCheck {
  const EvidenceCheck({
    required this.id,
    required this.photo,
    required this.photoPath,
    required this.status,
    this.result,
    this.errorMessage,
  });

  /// Cambia en cada intento. Sirve para ignorar la respuesta de un intento
  /// viejo si mientras tanto se mandó otra foto.
  final int id;

  /// La foto como la eligió el usuario, para mostrarla en el panel.
  final Uint8List photo;

  /// Dónde quedó en Storage.
  final String photoPath;

  final VerificationStatus status;

  /// Lo que dijo el verificador. Null mientras verifica o si falló.
  final VerificationResult? result;

  /// Mensaje para el usuario cuando no se pudo verificar.
  final String? errorMessage;

  EvidenceCheck copyWith({
    VerificationStatus? status,
    VerificationResult? result,
    String? errorMessage,
  }) {
    return EvidenceCheck(
      id: id,
      photo: photo,
      photoPath: photoPath,
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
