// la preferencia de verificar fotos guardada en una variable

import 'package:habuu/data/datasources/verification_preferences.dart';

class FakeVerificationPreferences implements VerificationPreferences {
  FakeVerificationPreferences({this.value});

  bool? value;

  @override
  Future<bool?> isEnabled() async => value;

  @override
  Future<void> setEnabled(bool enabled) async => value = enabled;
}
