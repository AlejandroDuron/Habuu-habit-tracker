import 'package:flutter/widgets.dart';

abstract final class Validators {
  static const passwordRules =
      'Mínimo 8 caracteres, con mayúsculas, números y símbolos';

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? notEmpty(String? value,
      [String message = 'Este campo es obligatorio']) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_emailRegExp.hasMatch(v)) return 'Ingresa un correo válido';
    return null;
  }

  
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Ingresa una contraseña';
    if (v.length < 8 ||
        !v.contains(RegExp(r'[A-Z]')) ||
        !v.contains(RegExp(r'[0-9]')) ||
        !v.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'La contraseña no cumple los requisitos';
    }
    return null;
  }

  
  static String? Function(String?) confirmPassword(
    TextEditingController original,
  ) {
    return (value) {
      if (value == null || value.isEmpty) return 'Confirma tu contraseña';
      if (value != original.text) return 'Las contraseñas no coinciden';
      return null;
    };
  }
}
