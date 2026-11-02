import '../../models/home/calendar_day.dart';

/// Datos de ejemplo del Home que todavía no vienen del backend.
abstract final class HomeMockData {
  static const days = [
    CalendarDay(day: '22'),
    CalendarDay(day: '23'),
    CalendarDay(day: '24'),
    CalendarDay(day: '25'),
    CalendarDay(day: '26', hasFrog: true, isToday: true),
    CalendarDay(day: '27'),
    CalendarDay(day: '28'),
    CalendarDay(day: '29'),
    CalendarDay(day: '30'),
  ];
}
