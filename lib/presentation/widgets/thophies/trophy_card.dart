import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

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
            color: locked ? HabuuColors.grey100 : HabuuColors.success0,
            shape: BoxShape.circle,
          ),
          child: image,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: HabuuText.bodySmMedium.copyWith(
            color: HabuuColors.success800,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: HabuuText.captionMdMedium.copyWith(
              color: HabuuColors.success800.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}