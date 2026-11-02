import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/tokens.dart';

/// Selector de hora para recordatorios de hábitos.
///
/// Muestra un campo con borde redondeado y un ícono de reloj.
/// Al tocarlo abre el [TimePickerDialog] nativo de Material.
class HabitTimePicker extends StatelessWidget {
  const HabitTimePicker({
    super.key,
    required this.selectedTime,
    required this.onChanged,
  });

  /// Hora seleccionada. Si es null, el campo muestra el hint.
  final TimeOfDay? selectedTime;

  final ValueChanged<TimeOfDay?> onChanged;

  Future<void> _pickTime(BuildContext context) async {
    final initial = selectedTime ?? TimeOfDay.now();

    // usamos AM/PM si el dispositivo lo tiene configurado así.
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: 'Elige la hora del recordatorio',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: HabuuColors.white100,
              dialHandColor: HabuuColors.primary500,
              dialBackgroundColor: HabuuColors.success0,
              entryModeIconColor: HabuuColors.primary500,
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: HabuuColors.primary500,
              onPrimary: HabuuColors.white100,
              surface: HabuuColors.success0,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasTime = selectedTime != null;

    // Formatea la hora en 12h con AM/PM, como es común en la región.
    final label = hasTime ? _formatTime(selectedTime!) : 'Ej. 8:00 AM';

    return Semantics(
      button: true,
      label: hasTime
          ? 'Recordatorio a las ${_formatTime(selectedTime!)}'
          : 'Elegir hora de recordatorio',
      child: InkWell(
        onTap: () => _pickTime(context),
        borderRadius: BorderRadius.circular(HabuuRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HabuuColors.success0,
            borderRadius: BorderRadius.circular(HabuuRadius.sm),
            border: Border.all(
              color: HabuuColors.primary500,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: HabuuIconColors.black,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: HabuuText.bodyLgRegular.copyWith(
                    color: hasTime
                        ? HabuuTextColors.primaryBlack
                        : HabuuTextColors.tertiaryGrey,
                  ),
                ),
              ),
              // Botón para borrar la hora si ya hay una seleccionada.
              if (hasTime)
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.close_rounded,
                      color: HabuuColors.grey400,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea la hora como "8:00 AM" o "2:30 PM".
  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
