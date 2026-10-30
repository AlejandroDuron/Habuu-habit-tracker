import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../models/home/calendar_day.dart';

/// Un día de la tira: número y, si se cumplió, la rana.
class DayChip extends StatelessWidget {
  const DayChip({super.key, required this.day});

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: day.isToday ? HabuuColors.success300 : HabuuColors.success0,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(2, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            day.day,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w600,
              color: day.isToday ? Colors.white : Colors.black,
            ),
          ),
          if (day.hasFrog)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Image.asset(
                HomeAssets.frogSmall,
                width: 30,
                height: 27,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
