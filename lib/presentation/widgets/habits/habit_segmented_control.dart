import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
 
class HabitSegmentedControl<T> extends StatelessWidget {
  const HabitSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });
 
  /// Las opciones en el orden en que se muestran
  final List<T> options;
 
  final T selected;
 
  /// Función que nos dice qué texto mostrar para cada opción,
  /// así el widget no necesita saber qué enum le pasamos
  final String Function(T option) labelOf;
 
  final ValueChanged<T> onChanged;
 
  static const double _height = 41;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: HabuuColors.black10,
        borderRadius: BorderRadius.circular(HabuuRadius.segment),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _Segment(
                label: labelOf(option),
                isSelected: option == selected,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}
 
/// Cada pestaña
class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
 
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HabuuRadius.segment);
 
    // Semantics para que el lector de pantalla diga que es un botón y si
    // está seleccionado
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        // AnimatedContainer hace que el fondo blanco cambie suave al tocar
        // otra opción, en vez de saltar de golpe
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? HabuuColors.white100 : Colors.transparent,
            borderRadius: radius,
            boxShadow: isSelected ? const [habuuCardShadow] : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: isSelected
                  ? HabuuText.bodySmSemibold.copyWith(
                      color: HabuuColors.primary500,
                    )
                  : HabuuText.bodySmMedium.copyWith(
                      color: HabuuColors.black60,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}