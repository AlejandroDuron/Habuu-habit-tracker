import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

/// Barra de progreso delgada de las tarjetas de reto.
class HabitProgressBar extends StatelessWidget {
  const HabitProgressBar({super.key, required this.fraction});

  /// Valor de 0 a 1.
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: HabuuColors.black10,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            width: c.maxWidth * fraction,
            decoration: BoxDecoration(
              color: HabuuColors.primary400,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
