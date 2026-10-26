import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/tokens.dart';

class TrophyCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const TrophyCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, height: 100),
            const SizedBox(height: 8),
            Text(
              title,
              style: HabuuText.bodySmMedium,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: HabuuText.bodySmMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}