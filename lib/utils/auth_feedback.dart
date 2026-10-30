import 'package:flutter/material.dart';
import 'package:habuu/config/theme/tokens.dart';

void showAuthError(BuildContext context, String? message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HabuuColors.error600,
        content: Text(
          message ?? 'Algo salió mal. Inténtalo de nuevo.',
          style: HabuuText.bodySmMedium.copyWith(color: HabuuColors.white100),
        ),
      ),
    );
}
