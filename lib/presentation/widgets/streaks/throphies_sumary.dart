import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/thophy/thophy_screen.dart';
import '../thophies/trophy_card.dart'; 

class TrophiesSummary extends StatelessWidget {
  const TrophiesSummary({
    super.key,
    required this.trophiesCount,
    this.latestTrophyImage = 'assets/images/trophy_day_completed.png',
    this.latestTrophyLabel = 'Día completado',
  });

  final int trophiesCount;
  final String latestTrophyImage;
  final String latestTrophyLabel;

  static const Color _accent = Color(0xFF2F7F9A);
  static const Color _button = Color(0xFF3A7F96);
  static const Color _textDark = Color(0xFF1D4452);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Trofeos Ganados',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w800,
            color: _accent,
          ),
        ),
        const SizedBox(height: 16),

        if (trophiesCount > 0)
          TrophyCard(
            title: latestTrophyLabel,
            imagePath: latestTrophyImage,
          )
        else
          Text(
            'Aún no has ganado trofeos',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textDark,
            ),
          ),

        const SizedBox(height: 20),

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
            backgroundColor: _button,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 12,
            ),
          ),
          child: Text(
            'Ver todos los trofeos',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              height: 24 / 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}