import 'package:flutter/material.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../shared/animated_frog.dart';

/// Estanque con Froggy encima, sobre un fondo radial.
/// Froggy salta si ya se cumplió algún hábito hoy; si no, duerme.
class PondHero extends StatelessWidget {
  const PondHero({super.key, required this.frogAwake});

  final bool frogAwake;

  // Dónde va Froggy, como fracción de la imagen del estanque:
  // parada sobre las hojas del centro.
  static const _frogCenterX = 0.47;
  static const _frogFeetY = 0.70;
  static const _frogWidth = 0.245;
  static const _hopHeight = 0.2;

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
                builder: (context, c) {
                  final imageLeft = c.maxWidth * -0.0465;
                  final imageTop = c.maxHeight * -0.0004;
                  final imageWidth = c.maxWidth * 1.093;
                  final imageHeight = c.maxHeight * 1.0763;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: imageLeft,
                        top: imageTop,
                        width: imageWidth,
                        height: imageHeight,
                        child: Image.asset(
                          HomeAssets.pond,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      _frog(
                        size: imageWidth * _frogWidth,
                        centerX: imageLeft + imageWidth * _frogCenterX,
                        feetY: imageTop + imageHeight * _frogFeetY,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _frog({
    required double size,
    required double centerX,
    required double feetY,
  }) {
    // AnimatedFrog deja espacio arriba para el salto y abajo para la sombra.
    // Las imágenes de Froggy no son cuadradas, así que también dejan un
    // margen abajo; por eso se baja la caja un poco más que los pies.
    final boxHeight = size * (1 + _hopHeight) + size * 0.1;
    final boxBottom = feetY + size * 0.125;

    return Positioned(
      left: centerX - size / 2,
      top: boxBottom - boxHeight,
      width: size,
      height: boxHeight,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: AnimatedFrog(
          key: ValueKey(frogAwake),
          asset: frogAwake ? HomeAssets.frogAwake : HomeAssets.frogSleeping,
          size: size,
          motion: frogAwake ? FrogMotion.hop : FrogMotion.breathe,
          hopHeight: _hopHeight,
          sideDistance: 0,
          semanticLabel: frogAwake ? 'Froggy despierta' : 'Froggy dormida',
        ),
      ),
    );
  }
}
