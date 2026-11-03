import 'package:flutter/material.dart';
import 'package:habuu/config/theme/tokens.dart';

void showAuthError(BuildContext context, String? message) {
  _show(
    context,
    message ?? 'Algo salió mal. Inténtalo de nuevo.',
    HabuuColors.error600,
  );
}

/// Aviso que no es un error, con el verde de la app.
void showAuthInfo(BuildContext context, String message) {
  _show(context, message, HabuuColors.primary500);
}

void _show(BuildContext context, String message, Color background) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: background,
        content: Text(
          message,
          style: HabuuText.bodySmMedium.copyWith(color: HabuuColors.white100),
        ),
      ),
    );
}
