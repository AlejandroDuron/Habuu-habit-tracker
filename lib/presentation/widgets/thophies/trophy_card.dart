import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrophyCard extends StatelessWidget {
  const TrophyCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.description,
    this.size = 100,
  });

  final String title;
  final String imagePath;

  /// Opcional: si es null, no se muestra.
  final String? description;

  /// Diámetro del círculo.
  final double size;

  static const Color _circleBg = Color(0xFFD6EDF5);
  static const Color _textDark = Color(0xFF1D4452);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.12),
          decoration: const BoxDecoration(
            color: _circleBg,
            shape: BoxShape.circle,
          ),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: size + 40,
            child: Text(
              description!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _textDark.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }
}