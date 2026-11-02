import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Lo máximo que puede pesar una foto de evidencia.
const maxEvidenceBytes = 100 * 1024;

const _startWidth = 1080;
const _minWidth = 320;
const _qualities = [85, 70, 55, 40];

/// Convierte una foto a JPG de [maxEvidenceBytes] o menos.
///
/// Corre en otro isolate, porque comprimir una foto grande tarda y
/// congelaría la pantalla.
Future<Uint8List> compressEvidencePhoto(Uint8List original) =>
    compute(_compress, original);

Uint8List _compress(Uint8List original) {
  final decoded = img.decodeImage(original);
  if (decoded == null) throw const PhotoCompressionException();

  // Las fotos del celular guardan su giro aparte; se aplica para que no
  // queden de lado.
  var image = img.bakeOrientation(decoded);
  if (image.width > _startWidth) {
    image = img.copyResize(image, width: _startWidth);
  }

  // Primero se baja la calidad. Si ni así cabe, se achica la foto y se
  // vuelve a intentar.
  while (true) {
    for (final quality in _qualities) {
      final jpg = img.encodeJpg(image, quality: quality);
      if (jpg.length <= maxEvidenceBytes) return jpg;
    }
    if (image.width <= _minWidth) throw const PhotoCompressionException();
    image = img.copyResize(image, width: (image.width * 0.75).round());
  }
}

/// La foto no se pudo leer o no hubo forma de dejarla en el peso máximo.
class PhotoCompressionException implements Exception {
  const PhotoCompressionException();

  String get message => 'No se pudo usar esa foto. Prueba con otra.';

  @override
  String toString() => message;
}
