import 'dart:typed_data';

abstract interface class EvidenceDataSource {
  /// Sube la foto de un hábito en un día y devuelve la ruta donde quedó.
  /// Cada subida queda en una ruta distinta, aunque sea el mismo día.
  Future<String> upload({
    required String habitId,
    required DateTime day,
    required Uint8List bytes,
  });

  /// Descarga una foto subida.
  Future<Uint8List> download(String path);

  /// Borra una foto subida.
  Future<void> delete(String path);
}
