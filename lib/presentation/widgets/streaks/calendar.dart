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
  // DateTime.weekday: lunes = 1 ... domingo = 7
  static const _weekLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  DateTime _focusedDay = DateTime.now();

  bool _isStreakDay(DateTime day) =>
      widget.streakDays.any((d) => isSameDay(d, day));

  TextStyle get _accentLabel => HabuuText.h6ExtraBold.copyWith(
        fontSize: 15,
        color: HabuuColors.success700,
      );

  Widget _dayCell(DateTime day, {bool highlighted = false, bool today = false}) {
    return Center(
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlighted ? HabuuColors.success200 : HabuuColors.grey100,
          shape: BoxShape.circle,
          border: today
              ? Border.all(color: HabuuColors.success700, width: 1.5)
              : null,
        ),
        child: Text(
          '${day.day}',
          style: HabuuText.bodySmSemibold.copyWith(
            color: highlighted ? HabuuColors.success800 : HabuuColors.grey400,
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
        border: Border.all(color: HabuuColors.success200, width: 1.5),
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

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextFormatter: (date, locale) {
            final month = DateFormat.MMMM(locale).format(date);
            final capitalized = month[0].toUpperCase() + month.substring(1);
            return '$capitalized ${date.year}';
          },
          titleTextStyle: HabuuText.h6ExtraBold.copyWith(
            fontSize: 20,
            color: HabuuColors.success700,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: HabuuColors.success700,
            size: 28,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: HabuuColors.success700,
            size: 28,
          ),
          headerPadding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: HabuuColors.success200, width: 1.5),
            ),
          ),
        ),

        calendarStyle: const CalendarStyle(outsideDaysVisible: false),

        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) => Center(
            child: Text(_weekLetters[day.weekday - 1], style: _accentLabel),
          ),
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