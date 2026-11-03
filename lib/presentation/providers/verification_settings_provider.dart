import 'package:flutter/foundation.dart';

import '../../data/datasources/verification_preferences.dart';

/// Guarda si el usuario aceptó que sus fotos se verifiquen. Lo usan el Home
/// (para preguntar la primera vez) y Perfil > Preferencias.
class VerificationSettingsProvider extends ChangeNotifier {
  VerificationSettingsProvider(this._preferences);

  final VerificationPreferences _preferences;

  bool? _enabled;
  Future<void>? _loading;

  /// null si todavía no se le ha preguntado.
  bool? get enabled => _enabled;

  /// Lee la preferencia guardada. Solo va al disco la primera vez.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      _enabled = await _preferences.isEnabled();
    } catch (e) {
      // Si no se puede leer, se vuelve a preguntar; no es grave.
      debugPrint('No se pudo leer la preferencia de verificación: $e');
    }
    notifyListeners();
  }

  /// La preferencia ya cargada.
  Future<bool?> current() async {
    await load();
    return _enabled;
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    notifyListeners();
    try {
      await _preferences.setEnabled(enabled);
    } catch (e) {
      debugPrint('No se pudo guardar la preferencia de verificación: $e');
    }
  }
}
