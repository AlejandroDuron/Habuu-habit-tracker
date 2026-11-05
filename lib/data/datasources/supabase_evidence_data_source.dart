import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/dates.dart';
import 'evidence_data_source.dart';
import 'home_data_source.dart';

class SupabaseEvidenceDataSource implements EvidenceDataSource {
  SupabaseEvidenceDataSource(this._client);

  final SupabaseClient _client;

  static const _bucket = 'habit-evidence';

  @override
  Future<String> upload({
    required String habitId,
    required DateTime day,
    required Uint8List bytes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const NotSignedInException();

    // Cada usuario tiene su carpeta; las políticas del bucket solo le dejan
    // tocar la suya. Cada foto va a una ruta nueva: si se reemplaza una,
    // el CDN de Storage sigue sirviendo la vieja hasta un minuto y Gemini
    // revisaría la foto anterior.
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${user.id}/$habitId/${isoDate(day)}_$stamp.jpg';

    try {
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      return path;
    } on StorageException catch (e) {
      debugPrint('Storage respondió con error ${e.statusCode}: ${e.message}');
      throw const HomeDataException('No se pudo subir la foto');
    } catch (e) {
      debugPrint('Error de conexión al subir la foto: $e');
      throw const HomeDataException('Revisa tu conexión e inténtalo de nuevo');
    }
  }

  @override
  Future<Uint8List> download(String path) {
    return _client.storage.from(_bucket).download(path);
  }

  @override
  Future<void> delete(String path) async {
    await _client.storage.from(_bucket).remove([path]);
  }
}
