import 'dart:typed_data';

import '../../utils/dates.dart';
import 'evidence_data_source.dart';

/// Guarda las fotos en memoria, sin red.
class FakeEvidenceDataSource implements EvidenceDataSource {
  final Map<String, Uint8List> _files = {};

  /// Fotos guardadas, por ruta.
  Map<String, Uint8List> get files => Map.unmodifiable(_files);

  @override
  Future<String> upload({
    required String habitId,
    required DateTime day,
    required Uint8List bytes,
  }) async {
    final path = '$habitId/${isoDate(day)}.jpg';
    _files[path] = bytes;
    return path;
  }

  @override
  Future<void> delete(String path) async {
    _files.remove(path);
  }
}
