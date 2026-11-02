import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';

/// Botón ancho de las pantallas de confirmación.
/// [ProfileActionButton.filled] lleva fondo de color y
/// [ProfileActionButton.outlined] solo el borde.
class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton.filled({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = HabuuColors.error700,
  }) : _outlined = false;

  const ProfileActionButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = HabuuColors.primary500,
  }) : _outlined = true;

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool _outlined;

  static const double width = 263;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HabuuRadius.sm),
    );
    const padding = EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    final text = Text(
      label,
      style: HabuuText.buttonGiant.copyWith(
        color: _outlined ? color : HabuuTextColors.primaryWhite,
      ),
    );

    return SizedBox(
      width: width,
      child: _outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.5),
                padding: padding,
                shape: shape,
              ),
              child: text,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: HabuuTextColors.primaryWhite,
                padding: padding,
                shape: shape,
              ),
              child: text,
            ),
    );
  }
}
