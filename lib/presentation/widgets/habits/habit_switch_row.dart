import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
 
class HabitSwitchRow extends StatelessWidget {
  const HabitSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
 
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
 
  @override
  Widget build(BuildContext context) {
    // MergeSemantics junta el texto y el switch para que el lector de
    // pantalla diga "Activar recordatorios, activado" de una sola vez
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: SizedBox(
          height: 28,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: HabuuText.bodyLgRegular.copyWith(
                    color: HabuuTextColors.primaryBlack,
                  ),
                ),
              ),

              SizedBox(
                width: 44,
                height: 24,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    activeThumbColor: HabuuColors.white100,
                    activeTrackColor: HabuuColors.primary500,
                    inactiveThumbColor: HabuuColors.white100,
                    inactiveTrackColor: HabuuColors.grey200,
                    trackOutlineColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}