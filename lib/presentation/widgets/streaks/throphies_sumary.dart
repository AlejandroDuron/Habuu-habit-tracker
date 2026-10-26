import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/thophy/thophy_screen.dart';

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
          'Trofeos Ganados',
          style: GoogleFonts.instrumentSans(
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
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TrophiesScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          child: Text(
            'Ver trofeos',
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
