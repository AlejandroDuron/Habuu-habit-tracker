import 'package:flutter/widgets.dart';

abstract final class Validators {
  static const passwordRules =
      'Mínimo 8 caracteres, con mayúsculas, números y símbolos';

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? notEmpty(
    String? value, [
    String message = 'Este campo es obligatorio',
  ]) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_emailRegExp.hasMatch(v)) return 'Ingresa un correo válido';
    return null;
  }

  static const passwordMinLength = 8;

  /// Al iniciar sesión solo se revisa el largo. Las demás reglas se piden al
  /// crear la contraseña, no al escribirla de nuevo.
  static String? loginPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < passwordMinLength) {
      return 'La contraseña tiene al menos $passwordMinLength caracteres';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Ingresa una contraseña';
    if (v.length < passwordMinLength ||
        !v.contains(RegExp(r'[A-Z]')) ||
        !v.contains(RegExp(r'[0-9]')) ||
        !v.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'La contraseña no cumple los requisitos';
    }
    return null;
  }

  /// Los mismos límites que los checks de la tabla `profiles`.
  static const fullNameMaxLength = 80;
  static const phoneMaxLength = 20;
  static final _phoneCharsRegExp = RegExp(r'^\+?[0-9 -]+$');
  static final oldestBirthday = DateTime(1900);

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa tu nombre';
    if (v.length > fullNameMaxLength) {
      return 'El nombre puede tener hasta $fullNameMaxLength caracteres';
    }
    return null;
  }

  /// Opcional: vacío es válido.
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > phoneMaxLength || !_phoneCharsRegExp.hasMatch(v)) {
      return 'Usa solo números, espacios, guiones y un + al inicio';
    }
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (digits < 8 || digits > 15) {
      return 'El teléfono debe tener entre 8 y 15 dígitos';
    }
    return null;
  }

  /// Opcional: null es válido. [today] existe para poder probarlo.
  static String? birthday(DateTime? value, {DateTime? today}) {
    if (value == null) return null;
    final now = today ?? DateTime.now();
    if (value.isAfter(DateTime(now.year, now.month, now.day))) {
      return 'La fecha no puede ser en el futuro';
    }
    if (value.isBefore(oldestBirthday)) return 'Ingresa una fecha válida';
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
