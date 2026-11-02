import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

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

  // No hay token de radio todavía (falta el grupo Spacing de Figma)
  static const double _outerRadius = 12;
  static const double _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_outerRadius),
        border: Border.all(color: HabuuColors.primary500, width: _borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_outerRadius - _borderWidth),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.center,
                    color: i == selected
                        ? HabuuColors.primary500
                        : Colors.transparent,
                    child: Text(
                      labels[i],
                      style: HabuuText.h5ExtraBold.copyWith(
                        fontSize: 18,
                        height: 24 / 18,
                        fontWeight: HabuuWeight.bold,
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
      ),
    );
  }
}