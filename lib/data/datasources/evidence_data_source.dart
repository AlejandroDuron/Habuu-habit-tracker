import 'dart:typed_data';

abstract interface class EvidenceDataSource {
  /// Sube la foto de un hábito en un día y devuelve la ruta donde quedó.
  /// Si ese día ya tenía foto, la reemplaza.
  Future<String> upload({
    required String habitId,
    required DateTime day,
    required Uint8List bytes,
  });

  /// Borra una foto subida.
  Future<void> delete(String path);
}
