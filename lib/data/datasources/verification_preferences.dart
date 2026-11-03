import 'package:shared_preferences/shared_preferences.dart';

/// Si el usuario quiere que sus fotos se verifiquen con Gemini.
abstract interface class VerificationPreferences {
  /// null si todavía no se le ha preguntado.
  Future<bool?> isEnabled();

  Future<void> setEnabled(bool enabled);
}

/// Se guarda solo en el teléfono: es una preferencia, no hace falta
/// mandarla a Supabase.
class SharedPrefsVerificationPreferences implements VerificationPreferences {
  static const _key = 'verificar_fotos';

  @override
  Future<bool?> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key);
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
