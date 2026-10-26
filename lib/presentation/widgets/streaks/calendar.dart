import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../config/theme/tokens.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
    this.streakDays = const {},
  });

  /// Días en los que el usuario cumplió la racha (se pintan en azul).
  final Set<DateTime> streakDays;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static const Color _accent = HabuuColors.success700;   // títulos y flechas
  static const Color _border = HabuuColors.success200;   // borde del contenedor
  static const Color _streakBg = HabuuColors.success200; // día de racha
  static const Color _dayBg = HabuuColors.grey50;        // día normal
  static const Color _dayText = HabuuColors.grey400;
  static const Color _dark = HabuuColors.success800;

  static const _weekLetters = ['L', 'M', 'M', 'J', 'V', 'D', 'S'];

  DateTime _focusedDay = DateTime.now();

  bool _isStreakDay(DateTime day) =>
      widget.streakDays.any((d) => isSameDay(d, day));

  Widget _dayCell(DateTime day, {bool highlighted = false, bool today = false}) {
    return Center(
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlighted ? _streakBg : _dayBg,
          shape: BoxShape.circle,
          border: today ? Border.all(color: _accent, width: 1.5) : null,
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: highlighted ? _dark : _dayText,
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
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,

        // Encabezado: "Febrero 2026" centrado con línea abajo
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextFormatter: (date, locale) {
            final month = DateFormat.MMMM(locale).format(date);
            final capitalized = month[0].toUpperCase() + month.substring(1);
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

        // Días de la semana: D L M M J V S
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
            // DateTime.weekday: lunes=1 ... domingo=7
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
          defaultBuilder: (context, day, _) =>
              _dayCell(day, highlighted: _isStreakDay(day)),
          todayBuilder: (context, day, _) =>
              _dayCell(day, highlighted: _isStreakDay(day), today: true),
          selectedBuilder: (context, day, _) =>
              _dayCell(day, highlighted: _isStreakDay(day)),
        ),
      ),
    );
  }
}