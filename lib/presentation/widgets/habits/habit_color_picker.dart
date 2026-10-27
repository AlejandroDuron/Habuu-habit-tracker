import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
 
/// Colores de la cuadrícula, en el mismo orden que en figma.
/// Los que tienen variable en figma usan el token; los demás vienen sueltos
/// en el diseño, así que los dejamos con su valor normal
const List<Color> habitColorOptions = [
  HabuuColors.warning300,
  Color(0xFFFED1A1),
  Color(0xFFAD9A9B),
  Color(0xFFC8A9A4),
  Color(0xFFFF9B9B),
  Color(0xFFFFD1D1),
  HabuuColors.info500,
  Color(0xFFFCBCFF),
  Color(0xFFC294FF),
  Color(0xFFD1D4FF),
  HabuuColors.success400,
  HabuuColors.success800,
  Color(0xFF87FFFF),
  Color(0xFFEBFFEA),
];
 
class HabitColorPicker extends StatelessWidget {
  const HabitColorPicker({
    super.key,
    required this.selectedColorValue,
    required this.onChanged,
  });
 
  final int selectedColorValue;
  final ValueChanged<int> onChanged;
 
  static const int _columns = 5;
  static const double _circleWidth = 41;
  static const double _circleHeight = 40;
  static const double _rowGap = 12;
 
  /// Es personalizado si el color guardado no está en la lista de figma
  bool get _isCustom => !habitColorOptions
      .any((c) => c.toARGB32() == selectedColorValue);
 
  /// Abre un diálogo con más colores, que son los primarios de nuestro desing system.
  Future<void> _pickCustomColor(BuildContext context) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Elige un color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final color in Colors.primaries)
              _ColorCircle(
                color: color,
                semanticLabel: 'Color personalizado',
                isSelected: color.toARGB32() == selectedColorValue,
                onTap: () => Navigator.pop(dialogContext, color),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
 
    // Si cerró el diálogo sin elegir, picked es null y no cambia nada
    if (picked != null) {
      onChanged(picked.toARGB32());
    }
  }
 
  @override
  Widget build(BuildContext context) {
    // Juntamos los 14 colores + el arcoíris en una sola lista de widgets
    // y luego los partimos en filas de 5 cada una
    final circles = <Widget>[
      for (var i = 0; i < habitColorOptions.length; i++)
        _ColorCircle(
          color: habitColorOptions[i],
          semanticLabel: 'Color ${i + 1}',
          isSelected: habitColorOptions[i].toARGB32() == selectedColorValue,
          onTap: () => onChanged(habitColorOptions[i].toARGB32()),
        ),
      _RainbowCircle(
        isSelected: _isCustom,
        customColor: _isCustom ? Color(selectedColorValue) : null,
        onTap: () => _pickCustomColor(context),
      ),
    ];
 
    return Center(
      // ConstrainedBox la deja crecer
      // hasta ese ancho y spaceBetween reparte el espacio que sobre o falte
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 321),
        child: Column(
          children: [
            for (var start = 0; start < circles.length; start += _columns) ...[
              if (start > 0) const SizedBox(height: _rowGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: circles.sublist(
                  start,
                  (start + _columns).clamp(0, circles.length),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
 
class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.color,
    required this.semanticLabel,
    required this.isSelected,
    required this.onTap,
  });
 
  final Color color;
  final String semanticLabel;
  final bool isSelected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: _CircleShape(
          isSelected: isSelected,
          decoration: BoxDecoration(color: color),
        ),
      ),
    );
  }
}
 
/// Círculo arcoíris para el color personalizado. Si ya se eligió uno,
/// mostramos ese color en el centro para que se vea cuál quedó
class _RainbowCircle extends StatelessWidget {
  const _RainbowCircle({
    required this.isSelected,
    required this.customColor,
    required this.onTap,
  });
 
  final bool isSelected;
  final Color? customColor;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Elegir color personalizado',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: _CircleShape(
          isSelected: isSelected,
          decoration: const BoxDecoration(
            gradient: SweepGradient(
              colors: [
                Color(0xFF000AFF),
                Color(0xFFFF0000),
                Color(0xFF04E7D9),
                Color(0xFFFFD707),
                Color(0xFFFF007A),
                Color(0xFF10FE28),
                Color(0xFF000AFF),
              ],
            ),
          ),
          center: customColor,
        ),
      ),
    );
  }
}

class _CircleShape extends StatelessWidget {
  const _CircleShape({
    required this.isSelected,
    required this.decoration,
    this.center,
  });
 
  final bool isSelected;
  final BoxDecoration decoration;
  final Color? center;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: HabitColorPicker._circleWidth,
      height: HabitColorPicker._circleHeight,
      decoration: decoration.copyWith(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? HabuuColors.primary500 : HabuuColors.black100,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: center == null && !isSelected
          ? null
          : Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: center ?? HabuuColors.white60,
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: HabuuIconColors.black,
                      )
                    : null,
              ),
            ),
    );
  }
}