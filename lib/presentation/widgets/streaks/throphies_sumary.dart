import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Trofeos Ganados',
          textAlign: TextAlign.center,
          style: HabuuText.h6ExtraBold.copyWith(
            fontSize: 20,
            color: HabuuColors.success700,
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
            style: HabuuText.bodySmMedium.copyWith(
              color: HabuuColors.success800,
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
            backgroundColor: HabuuColors.success700,
            foregroundColor: HabuuColors.white100,
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
            style: HabuuText.subtitleSmMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: HabuuColors.white100,
            ),
          ),
        ),
      ],
    );
  }
}