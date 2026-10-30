import 'package:flutter/material.dart';
import 'package:habuu/config/theme/tokens.dart';

/// Botón principal verde de las pantallas de autenticación.
/// Con [isLoading] muestra un indicador y se desactiva.
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width = 240,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: HabuuColors.primary500,
            foregroundColor: HabuuColors.white100,
            // Mismo aspecto mientras carga (no se ve "gris" de desactivado).
            disabledBackgroundColor: HabuuColors.primary500,
            disabledForegroundColor: HabuuColors.white100,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: HabuuColors.white100,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: HabuuText.subtitleSmMedium.copyWith(
                      fontWeight: HabuuWeight.bold,
                      color: HabuuColors.white100,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
