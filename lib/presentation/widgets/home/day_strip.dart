import 'package:flutter/material.dart';
import '../../models/home/calendar_day.dart';
import 'day_chip.dart';

/// Lista horizontal de días.
class DayStrip extends StatelessWidget {
  const DayStrip({super.key, required this.days});

  final List<CalendarDay> days;

  @override
  Widget build(BuildContext context) {
    // Los días que no caben se cortan en el borde del contenedor.
    // El padding vertical deja espacio para la sombra de cada día.
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => DayChip(day: days[i]),
      ),
    );
  }
}
