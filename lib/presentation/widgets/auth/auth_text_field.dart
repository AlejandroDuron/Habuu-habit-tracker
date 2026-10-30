import 'package:flutter/material.dart';
import 'package:habuu/config/theme/tokens.dart';

/// Borde redondeado compartido por los campos y las casillas de código.
OutlineInputBorder authInputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );

/// Etiqueta + campo de texto + texto de ayuda opcional.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = 'example@correo.com',
    this.obscureText = false,
    this.validator,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  /// Hint típico para los campos de contraseña.
  static const passwordHint = '****************';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HabuuText.subtitleSmMedium.copyWith(
            fontWeight: HabuuWeight.semibold,
            color: HabuuIconColors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          onFieldSubmitted: onFieldSubmitted,
          style: HabuuText.bodySmMedium,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: HabuuColors.grey0,
            hintText: hint,
            hintStyle: HabuuText.captionMdMedium.copyWith(
              color: HabuuColors.grey400,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: authInputBorder(HabuuColors.primary200),
            focusedBorder: authInputBorder(HabuuColors.primary500),
            errorBorder: authInputBorder(HabuuColors.error500),
            focusedErrorBorder: authInputBorder(HabuuColors.error500),
            errorStyle: HabuuText.captionMdMedium.copyWith(
              color: HabuuColors.error600,
            ),
            errorMaxLines: 2,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            helperText!,
            style: HabuuText.captionMdMedium.copyWith(
              color: HabuuTextColors.secondaryGrey,
            ),
          ),
        ],
      ],
    );
  }
}
