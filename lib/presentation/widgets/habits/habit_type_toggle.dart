import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
 
class HabitTypeToggle extends StatelessWidget {
  const HabitTypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });
 
  final HabitType selected;
  final ValueChanged<HabitType> onChanged;
  static const double height = 60;
  static const double _borderWidth = 1.5;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: HabuuColors.primary500,
          width: _borderWidth,
        ),
        borderRadius: BorderRadius.circular(HabuuRadius.sm),
      ),
      // ClipRRect recorta el fondo verde del botón activo para que esten
      // las esquinas redondas del borde
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HabuuRadius.sm - _borderWidth),
        child: Row(
          children: [
            // Un botón por cada tipo del enum. Si algún día se agrega otro
            // tipo, aparece solo sin tocar este widget
            for (final type in HabitType.values)
              Expanded(
                child: _ToggleOption(
                  label: type.label,
                  isSelected: type == selected,
                  onTap: () => onChanged(type),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
 
/// Cada mitad del botón doble
class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
 
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    // Semantics para que el lector de pantalla diga que es un botón y si
    // está seleccionado
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? HabuuColors.primary500 : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              // FittedBox con scaleDown achica el texto solo si no cabe.
              // En Figma la pantalla mide 440 px, pero en un teléfono de
              // 360 px "habito frecuente" se desbordaría, así que lo achicamos un poco para que siempre quepa
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: HabuuText.buttonGiant.copyWith(
                    color: isSelected
                        ? HabuuTextColors.primaryWhite
                        : HabuuTextColors.accent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}