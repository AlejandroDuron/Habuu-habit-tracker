import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import 'profile_field_style.dart';

/// Campo de fecha del perfil: al tocarlo abre el calendario.
/// Es un [FormField], así su [validator] corre con el resto del formulario.
class ProfileDateField extends StatelessWidget {
  const ProfileDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.validator,
    this.hint = 'dd/mm/aaaa',
    this.pickerTitle = 'Elige una fecha',
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final FormFieldValidator<DateTime>? validator;
  final String hint;
  final String pickerTitle;

  static final _format = DateFormat('dd/MM/yyyy');

  Future<void> _pick(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) async {
    final current = field.value;
    // Si no hay fecha, el calendario abre 20 años atrás: es una fecha de
    // nacimiento, no algo de esta semana.
    var initial = current ?? DateTime(lastDate.year - 20, 1, 1);
    if (initial.isAfter(lastDate)) initial = lastDate;
    if (initial.isBefore(firstDate)) initial = firstDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: current == null
          ? DatePickerMode.year
          : DatePickerMode.day,
      helpText: pickerTitle,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: HabuuColors.primary500,
            onPrimary: HabuuColors.white100,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    field.didChange(picked);
    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFieldFrame(
      label: label,
      child: FormField<DateTime>(
        initialValue: value,
        validator: validator,
        builder: (field) {
          final date = field.value;
          final text = date == null ? null : _format.format(date);
          return Semantics(
            button: true,
            label: text == null ? '$label, sin elegir' : '$label, $text',
            excludeSemantics: true,
            child: InkWell(
              onTap: () => _pick(context, field),
              borderRadius: BorderRadius.circular(HabuuRadius.sm),
              child: InputDecorator(
                isEmpty: date == null,
                decoration: profileInputDecoration(
                  hint: hint,
                  trailingIcon: ProfileAssets.calendar,
                  errorText: field.errorText,
                ),
                child: Text(text ?? '', style: profileFieldTextStyle),
              ),
            ),
          );
        },
      ),
    );
  }
}
