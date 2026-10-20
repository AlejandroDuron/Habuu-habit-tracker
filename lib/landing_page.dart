import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla Landing de Habuu.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key, this.onLogin, this.onCreateAccount});

  final VoidCallback? onLogin;
  final VoidCallback? onCreateAccount;

  static const double _designWidth = 440;

  // Colores medidos de la imagen del diseño.
  static const Color _green = Color(0xFF165239);
  static const Color _ink = Color(0xFF050505);
  static const List<Color> _sky = [
    Color(0xFFD3F0F6),
    Color(0xFFCEF0F0),
    Color(0xFFC9F0EA),
    Color(0xFFC3F2E3),
    Color(0xFFBFF2DB),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double s = constraints.maxWidth / _designWidth;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _sky,
                stops: [0.0, 0.25, 0.5, 0.7, 1.0],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Ilustración inferior (hongos, iris, totoras).
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/scenery.png',
                    width: constraints.maxWidth,
                    fit: BoxFit.fitWidth,
                    filterQuality: FilterQuality.high,
                  ),
                ),

                // Libélulas laterales.
                _sprite('dragonfly_left', s, left: 6, top: 396, w: 54),
                _sprite('dragonfly_right', s, left: 372, top: 404, w: 42),

                // Título.
                Positioned(
                  top: 75 * s,
                  left: 0,
                  right: 0,
                  child: Text.rich(
                    TextSpan(
                      // Texto idéntico al diseño (incluye "habitos" sin tilde).
                      // Si lo quieres corregir: "hábitos".
                      text: 'Deja que ',
                      children: const [
                        TextSpan(
                          text: 'Habuu',
                          style: TextStyle(color: _green),
                        ),
                        TextSpan(text: ' te\nayude a mejorar\ntus habitos'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.noScaling,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40 * s,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -0.3 * s,
                      color: _ink,
                    ),
                  ),
                ),

                // Botón "Iniciar sesión" (relleno).
                Positioned(
                  left: 127 * s,
                  top: 260 * s,
                  width: 186 * s,
                  height: 60 * s,
                  child: _HabuuButton(
                    label: 'Iniciar sesión',
                    filled: true,
                    scale: s,
                    onTap: onLogin,
                  ),
                ),

                // Botón "Crear cuenta" (contorno).
                Positioned(
                  left: 127 * s,
                  top: 372 * s,
                  width: 186 * s,
                  height: 60 * s,
                  child: _HabuuButton(
                    label: 'Crear cuenta',
                    filled: false,
                    scale: s,
                    onTap: onCreateAccount,
                  ),
                ),

                // Ranas (van encima de los botones).
                _sprite('frog_button', s, left: 284, top: 232, w: 68),
                _sprite('frog_mushroom', s, left: 96, top: 398, w: 62),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sprite(
    String name,
    double s, {
    required double left,
    required double top,
    required double w,
  }) {
    return Positioned(
      left: left * s,
      top: top * s,
      width: w * s,
      child: IgnorePointer(
        child: Image.asset(
          'assets/images/$name.png',
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _HabuuButton extends StatelessWidget {
  const _HabuuButton({
    required this.label,
    required this.filled,
    required this.scale,
    this.onTap,
  });

  final String label;
  final bool filled;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12 * scale);

    return Material(
      color: filled ? LandingPage._green : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: filled
            ? BorderSide.none
            : BorderSide(color: LandingPage._green, width: 1.5 * scale),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            textScaler: TextScaler.noScaling,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19 * scale,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : LandingPage._green,
            ),
          ),
        ),
      ),
    );
  }
}
