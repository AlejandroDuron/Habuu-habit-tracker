import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/tokens.dart';

class StreakHeader extends StatelessWidget {
  const StreakHeader({
    super.key,
    required this.streakCount,
    this.message = '¡Froggy ha despertado, sigue así!',
  });

  final int streakCount;
  final String message;

  static const Color _textDark = HabuuColors.success800;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 32),
      decoration: const BoxDecoration(gradient: HabuuGradients.mintToSky),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Froggy centrado
          Center(
            child: Image.asset(
              'assets/images/frog_button.png',
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),

          // Texto + patito
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streakCount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 56,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streakCount == 1 ? 'Día de racha' : 'Días de racha',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                 'assets/images/frog_button.png',
                height: 64,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}