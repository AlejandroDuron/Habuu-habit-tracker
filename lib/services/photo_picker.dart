import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Abre la galería para elegir una foto. Devuelve null si el usuario
/// la cerró sin elegir nada.
///
/// La galería ya entrega la foto reducida, así comprimirla después es
/// más rápido.
Future<Uint8List?> pickEvidencePhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1600,
    imageQuality: 90,
  );
  return file?.readAsBytes();
}
