import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrophyCard extends StatelessWidget {
  const TrophyCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.description,
    this.size = 100,
    this.locked = false,
  });

  final String title;
  final String imagePath;
  final String? description;
  final double size;

  /// Si es true, se muestra en gris (trofeo aún no ganado).
  final bool locked;

  static const Color _circleBg = Color(0xFFD6EDF5);
  static const Color _lockedBg = Color(0xFFE0E0E0);
  static const Color _textDark = Color(0xFF1D4452);

  // Convierte la imagen a escala de grises
  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(imagePath, fit: BoxFit.contain);
    if (locked) {
      image = ColorFiltered(colorFilter: _grayscale, child: image);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.12),
          decoration: BoxDecoration(
            color: locked ? _lockedBg : _circleBg,
            shape: BoxShape.circle,
          ),
          child: image,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textDark,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textDark.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}