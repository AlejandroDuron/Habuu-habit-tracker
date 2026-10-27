import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
 
/// Íconos disponibles, en orden. La posición en esta lista es el iconIndex
/// que se guarda en habits
/// En figma los 5 botones usan el mismo ícono de ejemplo, así que elegimos
/// íconos del material que van con las categorías
const List<IconData> habitIconOptions = [
  Icons.water_drop_outlined,
  Icons.local_florist_outlined,
  Icons.directions_run_rounded,
  Icons.menu_book_outlined,
  Icons.self_improvement_rounded,
];
 
/// Nombres para el lector de pantalla, en el mismo orden que los íconos
const List<String> _iconNames = [
  'Agua',
  'Plantas',
  'Ejercicio',
  'Estudio',
  'Descanso',
];
 
/// Devuelve el ícono de un hábito según su iconIndex.
/// Si el índice no existe, usamos el primero
/// en vez de dejar que la app truene con un RangeError
IconData habitIconFor(int iconIndex) {
  if (iconIndex < 0 || iconIndex >= habitIconOptions.length) {
    return habitIconOptions.first;
  }
  return habitIconOptions[iconIndex];
}
 
class HabitIconPicker extends StatelessWidget {
  const HabitIconPicker({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });
 
  final int selectedIndex;
  final ValueChanged<int> onChanged;
 
  static const double _maxButtonSize = 56;
  static const double _maxGap = 18;
 
  @override
  Widget build(BuildContext context) {
    // LayoutBuilder: en figma son 5 botones de 56 px con 18 px
    // de separación. En un teléfono de 360 px solo hay
    // 290 px disponibles, así que achicamos los botones si no caben
    return LayoutBuilder(
      builder: (context, constraints) {
        const count = 5;
        final fitted = (constraints.maxWidth - _maxGap * (count - 1)) / count;
        final size = fitted < _maxButtonSize ? fitted : _maxButtonSize;
 
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < habitIconOptions.length; i++) ...[
              if (i > 0) const SizedBox(width: _maxGap),
              _IconOption(
                icon: habitIconOptions[i],
                semanticLabel: _iconNames[i],
                size: size,
                isSelected: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ],
          ],
        );
      },
    );
  }
}
 
class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.icon,
    required this.semanticLabel,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });
 
  final IconData icon;
  final String semanticLabel;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HabuuRadius.sm);
 
    // En figma no hay estado seleccionado, así que usamos el mismo tema
    // que en los chips
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: isSelected ? HabuuColors.primary500 : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: isSelected ? HabuuColors.primary500 : HabuuColors.black100,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? HabuuIconColors.white : HabuuIconColors.black,
            ),
          ),
        ),
      ),
    );
  }
}