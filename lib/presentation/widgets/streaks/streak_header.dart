
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakHeader extends StatelessWidget {
  const StreakHeader({
    super.key,
    required this.streakCount,
  });

  final int streakCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Racha actual',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF050505),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$streakCount días',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            height: 36 / 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF050505),
          ),
        ),
      ],
    );
  }
}
