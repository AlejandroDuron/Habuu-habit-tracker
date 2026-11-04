import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'profile_field_style.dart';

/// Campo de texto del perfil. Con [readOnly] se ve en gris y no se puede
/// enfocar, pero el lector de pantalla lo sigue leyendo.
class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.leadingIcon,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.focusNode,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final String? leadingIcon;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return ProfileFieldFrame(
      label: label,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        readOnly: readOnly,
        canRequestFocus: !readOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        autofillHints: readOnly ? null : autofillHints,
        inputFormatters: inputFormatters,
        onFieldSubmitted: onFieldSubmitted,
        style: readOnly ? profileReadOnlyTextStyle : profileFieldTextStyle,
        decoration: profileInputDecoration(
          hint: hint,
          leadingIcon: leadingIcon,
        ),
      ),
    );
  }
}
