/// Un día de la tira de calendario del Home.
class CalendarDay {
  const CalendarDay({
    required this.day,
    this.hasFrog = false,
    this.isToday = false,
  });

  final String day;

  /// Si es true, se dibuja la rana debajo del número (día cumplido).
  final bool hasFrog;
  final bool isToday;
}
