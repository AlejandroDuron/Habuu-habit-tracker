import 'package:flutter/material.dart';
import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';

/// Ilustración de la rana en el estanque, sobre un fondo radial.
class PondHero extends StatelessWidget {
  const PondHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 264,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const RadialGradient(
                  radius: 0.83,
                  colors: [
                    HabuuColors.info300,
                    Color(0xFFB1C7D5),
                    Color(0xFF8DC5D7),
                    HabuuColors.success300,
                  ],
                  stops: [0, 0.16827, 0.2524, 0.33654],
                ),
              ),
            ),
          ),
          // La imagen sobresale 9px a la izquierda y 11px a la derecha.
          Positioned(
            left: -9,
            right: -11,
            top: 0,
            height: 271,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: LayoutBuilder(
                builder: (context, c) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: c.maxWidth * -0.0465,
                      top: c.maxHeight * -0.0004,
                      width: c.maxWidth * 1.093,
                      height: c.maxHeight * 1.0763,
                      child: Image.asset(
                        HomeAssets.frogHero,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
