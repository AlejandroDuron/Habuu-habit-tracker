import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

/// Selector de período: Hoy / Semana / Todo.
/// El activo ocupa toda la altura del contenedor con esquinas redondeadas
/// adaptadas a su posición (igual que en el diseño de Figma).
class PeriodSegment extends StatelessWidget {
  const PeriodSegment({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  // Radio del contenedor exterior
  static const double _outerRadius = HabuuRadius.segment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        // Fondo menta claro, igual que en la imagen
        color: HabuuColors.primary100,
        borderRadius: BorderRadius.circular(_outerRadius),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  // Sin margen: el activo llena todo el alto
                  decoration: BoxDecoration(
                    color: i == selected
                        ? HabuuColors.primary500
                        : Colors.transparent,
                    borderRadius: _radiusFor(i, labels.length),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: HabuuText.bodySmSemibold.copyWith(
                      color: i == selected
                          ? HabuuColors.white100
                          : HabuuColors.primary500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// El primer y último elemento heredan el radio del contenedor en sus
  /// esquinas exteriores; los del medio no tienen radio.
  BorderRadius _radiusFor(int i, int total) {
    const r = Radius.circular(_outerRadius);
    if (total == 1) return BorderRadius.all(r);
    if (i == 0) return const BorderRadius.only(topLeft: r, bottomLeft: r);
    if (i == total - 1) return const BorderRadius.only(topRight: r, bottomRight: r);
    return BorderRadius.zero;
  }
}
