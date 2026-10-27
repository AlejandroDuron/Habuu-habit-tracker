import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
 
class HabitDayPicker extends StatelessWidget {
  const HabitDayPicker({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
    required this.allDay,
    required this.onAllDayChanged,
  });
 
  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onDaysChanged;
  final bool allDay;
  final ValueChanged<bool> onAllDayChanged;

  static const _week = [
    (letter: 'D', day: DateTime.sunday),
    (letter: 'L', day: DateTime.monday),
    (letter: 'M', day: DateTime.tuesday),
    (letter: 'M', day: DateTime.wednesday),
    (letter: 'J', day: DateTime.thursday),
    (letter: 'V', day: DateTime.friday),
    (letter: 'S', day: DateTime.saturday),
  ];
 
  static const _dayNames = {
    DateTime.monday: 'Lunes',
    DateTime.tuesday: 'Martes',
    DateTime.wednesday: 'Miércoles',
    DateTime.thursday: 'Jueves',
    DateTime.friday: 'Viernes',
    DateTime.saturday: 'Sábado',
    DateTime.sunday: 'Domingo',
  };
 
  static const double _maxButtonSize = 45;
  static const double _minGap = 4;
 
  void _toggleDay(int day) {
    // Creamos un Set nuevo en vez de modificar el que recibimos, porque
    // ese Set es del padre y el estado se cambia solo con setState allá
    final updated = {...selectedDays};
    if (!updated.remove(day)) {
      updated.add(day);
    }
    onDaysChanged(updated);
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'En este día',
                style: HabuuText.subtitleSmMedium.copyWith(
                  color: HabuuTextColors.primaryBlack,
                ),
              ),
            ),
            _AllDayCheckbox(value: allDay, onChanged: onAllDayChanged),
          ],
        ),
        const SizedBox(height: 18),
        // LayoutBuilder, en Figma cada botón mide 45 px, pero en
        // un teléfono de 360 px los 7 botones no caben. Calculamos el
        // tamaño según el ancho real que nos da el padre
        LayoutBuilder(
          builder: (context, constraints) {
            final fitted =
                (constraints.maxWidth - _minGap * (_week.length - 1)) /
                    _week.length;
            final size = fitted < _maxButtonSize ? fitted : _maxButtonSize;
 
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final item in _week)
                  _DayButton(
                    letter: item.letter,
                    semanticLabel: _dayNames[item.day]!,
                    size: size,
                    isSelected: selectedDays.contains(item.day),
                    onTap: () => _toggleDay(item.day),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
 
/// Cada cuadrito de día
class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.letter,
    required this.semanticLabel,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });
 
  final String letter;
  final String semanticLabel;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HabuuRadius.sm);
 
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      // excludeSemantics para que no lea también la letra suelta
      excludeSemantics: true,
      child: Material(
        color: isSelected ? HabuuColors.success0 : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: HabuuColors.primary500, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Text(
                letter,
                style: HabuuText.buttonLarge.copyWith(
                  color: HabuuTextColors.accent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AllDayCheckbox extends StatelessWidget {
  const _AllDayCheckbox({required this.value, required this.onChanged});
 
  final bool value;
  final ValueChanged<bool> onChanged;
 
  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: 'Todo el día',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(HabuuRadius.tiny),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Todo el día',
                style: HabuuText.bodySmMedium.copyWith(
                  color: HabuuTextColors.primaryBlack,
                ),
              ),
              const SizedBox(width: 18),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? HabuuColors.primary500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(HabuuRadius.tiny),
                  border: Border.all(color: HabuuColors.primary500, width: 1.5),
                ),
                child: value
                    ? const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: HabuuIconColors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}