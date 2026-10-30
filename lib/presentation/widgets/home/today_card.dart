import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/tokens.dart';
import '../../models/home/calendar_day.dart';
import 'day_strip.dart';
import 'pond_hero.dart';

/// Tarjeta "Hoy": tira de días y la rana en el estanque.
class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.days});

  final List<CalendarDay> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: HabuuColors.white40,
        border: Border.all(color: HabuuColors.primary200),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Hoy',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                height: 32 / 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1C1E),
              ),
            ),
          ),
          const SizedBox(height: 22),
          DayStrip(days: days),
          const SizedBox(height: 22),
          const PondHero(),
        ],
      ),
    );
  }
}
