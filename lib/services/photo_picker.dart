import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Abre la galería para elegir una foto. Devuelve null si el usuario
/// la cerró sin elegir nada.
Future<Uint8List?> pickEvidencePhoto() => _pick(ImageSource.gallery);

/// Abre la cámara para tomar una foto. Devuelve null si el usuario
/// la cerró sin tomar ninguna.
Future<Uint8List?> takeEvidencePhoto() => _pick(ImageSource.camera);

/// La foto ya llega reducida, así comprimirla después es más rápido.
Future<Uint8List?> _pick(ImageSource source) async {
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600,
    imageQuality: 90,
  );
  return file?.readAsBytes();
}
