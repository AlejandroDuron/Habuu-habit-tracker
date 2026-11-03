/// Quita la hora de una fecha, para comparar solo el día.
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Fecha en formato "2026-11-01", como la guarda una columna date.
String isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Cuántos días tiene un mes. El día 0 del mes siguiente es el último de este.
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

DateTime weekStartOf(DateTime date) {
  final day = dateOnly(date);
  return day.subtract(Duration(days: day.weekday - 1));
}
