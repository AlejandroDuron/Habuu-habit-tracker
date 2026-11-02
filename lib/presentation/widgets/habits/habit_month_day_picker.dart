import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../config/theme/tokens.dart';

/// Calendario mensual para que el usuario elija un día del mes.
///
/// Usa [table_calendar] con el mismo estilo visual que el calendario
/// de la pantalla de Rachas. Devuelve el número del día seleccionado (1–31).
class HabitMonthDayPicker extends StatefulWidget {
  const HabitMonthDayPicker({
    super.key,
    required this.selectedDay,
    required this.onChanged,
  });

  /// Día del mes seleccionado (1–31), o null si no hay selección.
  final int? selectedDay;

  final ValueChanged<int?> onChanged;

  @override
  State<HabitMonthDayPicker> createState() => _HabitMonthDayPickerState();
}

class _HabitMonthDayPickerState extends State<HabitMonthDayPicker> {
  static const Color _accent = HabuuColors.primary500;
  static const Color _border = HabuuColors.primary200;
  static const Color _selectedBg = HabuuColors.primary500;
  static const Color _dayBg = HabuuColors.grey50;
  static const Color _dayText = HabuuColors.grey400;

  static const _weekLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  bool _isSelected(DateTime day) =>
      widget.selectedDay != null && day.day == widget.selectedDay;

  Widget _dayCell(DateTime day, {bool today = false}) {
    final selected = _isSelected(day);
    return Center(
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _selectedBg : _dayBg,
          shape: BoxShape.circle,
          border: today && !selected
              ? Border.all(color: _accent, width: 1.5)
              : null,
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? HabuuColors.white100 : _dayText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(bottom: 8),
      child: TableCalendar(
        locale: 'es_ES',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.horizontalSwipe,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        rowHeight: 46,
        daysOfWeekHeight: 36,
        onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),

        onDaySelected: (selectedDay, focusedDay) {
          setState(() => _focusedDay = focusedDay);
          widget.onChanged(selectedDay.day);
        },

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextFormatter: (date, locale) {
            final month = DateFormat.MMMM(locale).format(date);
            final capitalized =
                month[0].toUpperCase() + month.substring(1);
            return '$capitalized ${date.year}';
          },
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _accent,
          ),
          leftChevronIcon:
              const Icon(Icons.chevron_left, color: _accent, size: 28),
          rightChevronIcon:
              const Icon(Icons.chevron_right, color: _accent, size: 28),
          headerPadding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _border, width: 1.5),
            ),
          ),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _accent,
          ),
          weekendStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _accent,
          ),
        ),

        calendarStyle: const CalendarStyle(outsideDaysVisible: false),

        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            final letter = _weekLetters[day.weekday - 1];
            return Center(
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _accent,
                ),
              ),
            );
          },
          defaultBuilder: (context, day, _) => _dayCell(day),
          todayBuilder: (context, day, _) => _dayCell(day, today: true),
          selectedBuilder: (context, day, _) => _dayCell(day),
        ),
      ),
    );
  }
}
