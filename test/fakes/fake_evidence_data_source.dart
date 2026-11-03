// guarda las fotos en un mapa en vez de subirlas a Storage

import 'dart:typed_data';

import 'package:habuu/data/datasources/evidence_data_source.dart';
import 'package:habuu/utils/dates.dart';

class FakeEvidenceDataSource implements EvidenceDataSource {
  final Map<String, Uint8List> photos = {};

  /// Para simular que falla la subida o la descarga.
  Object? errorToThrow;

  void _failIfNeeded() {
    final error = errorToThrow;
    if (error != null) throw error;
  }

  @override
  Future<String> upload({
    required String habitId,
    required DateTime day,
    required Uint8List bytes,
  }) async {
    _failIfNeeded();
    final path = 'user-1/$habitId/${isoDate(day)}.jpg';
    photos[path] = bytes;
    return path;
  }

  @override
  Future<Uint8List> download(String path) async {
    _failIfNeeded();
    final photo = photos[path];
    if (photo == null) throw Exception('No existe $path');
    return photo;
  }

  @override
  Future<void> delete(String path) async {
    photos.remove(path);
  }
}
