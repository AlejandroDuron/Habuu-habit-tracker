
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrophiesSummary extends StatelessWidget {
  const TrophiesSummary({
    super.key,
    required this.trophiesCount,
  });

  final int trophiesCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trofeos obtenidos',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF050505),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$trophiesCount trofeos',
          style: GoogleFonts.instrumentSans(
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
