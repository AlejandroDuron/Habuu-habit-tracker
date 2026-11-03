import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla Landing de Habuu.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key, this.onLogin, this.onCreateAccount});

  final VoidCallback? onLogin;
  final VoidCallback? onCreateAccount;

  static const double _designWidth = 440;
  static const double _contentMaxWidth = 440;

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
          final scale = math
              .min(
                constraints.maxWidth / _designWidth,
                constraints.maxHeight / 640,
              )
              .clamp(.75, 1.0);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _sky,
                stops: [0.0, 0.25, 0.5, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/landing/scenery.png',
                      width: constraints.maxWidth,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, safeConstraints) {
                      final contentWidth = math.min(
                        safeConstraints.maxWidth,
                        _contentMaxWidth,
                      );
                      final buttonWidth = math.min(
                        contentWidth - 48 * scale,
                        220 * scale,
                      );

                      return Center(
                        child: SizedBox(
                          width: contentWidth,
                          height: safeConstraints.maxHeight,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24 * scale,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 64 * scale),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Deja que ',
                                      children: const [
                                        TextSpan(
                                          text: 'Habuu',
                                          style: TextStyle(color: _green),
                                        ),
                                        TextSpan(
                                          text: ' te\nayude a mejorar\ntus habitos',
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 40 * scale,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                      letterSpacing: -0.3 * scale,
                                      color: _ink,
                                    ),
                                  ),
                                  SizedBox(height: 80 * scale),
                                  SizedBox(
                                    width: buttonWidth + 40 * scale,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: buttonWidth,
                                              height: 56 * scale,
                                              child: _HabuuButton(
                                                label: 'Iniciar sesión',
                                                filled: true,
                                                scale: scale,
                                                onTap: onLogin,
                                              ),
                                            ),
                                            SizedBox(height: 24 * scale),
                                            SizedBox(
                                              width: buttonWidth,
                                              height: 56 * scale,
                                              child: _HabuuButton(
                                                label: 'Crear cuenta',
                                                filled: false,
                                                scale: scale,
                                                onTap: onCreateAccount,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: -24 * scale,
                                          width: 58 * scale,
                                          child: IgnorePointer(
                                            child: Image.asset(
                                              'assets/images/calendar/one_month.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          bottom: -16 * scale,
                                          width: 54 * scale,
                                          child: IgnorePointer(
                                            child: Image.asset(
                                              'assets/images/calendar/discipline.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 100 * scale),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 8 * scale,
                  bottom: constraints.maxHeight * .35,
                  width: 46 * scale,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/landing/dragonfly_left.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  right: 8 * scale,
                  bottom: constraints.maxHeight * .34,
                  width: 38 * scale,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/landing/dragonfly_right.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
            textAlign: TextAlign.center,
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
