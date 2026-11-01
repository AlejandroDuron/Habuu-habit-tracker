import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

/// Cabecera de "Tus Hábitos": título centrado y botón de más opciones (⋯).
class HabitsListHeader extends StatelessWidget {
  const HabitsListHeader({super.key, this.onMore});

  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Espacio simétrico al ícono para que el título quede centrado
        const SizedBox(width: 28),
        Expanded(
          child: Text(
            'Tus Hábitos',
            textAlign: TextAlign.center,
            style: HabuuText.h5ExtraBold.copyWith(
              color: HabuuTextColors.title,
            ),
          ),
        ),
        GestureDetector(
          onTap: onMore,
          behavior: HitTestBehavior.opaque,
          child: Semantics(
            label: 'Más opciones',
            button: true,
            child: Text(
              '•••',
              style: HabuuText.subtitleMdBold.copyWith(
                color: HabuuTextColors.title,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
