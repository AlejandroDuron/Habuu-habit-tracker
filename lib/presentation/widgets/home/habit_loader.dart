import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/tokens.dart';
import '../../../utils/habit_style.dart';

/// Ícono del hábito dentro de un anillo de su color.
/// Pendiente, el anillo está vacío; al completarse se llena.
class HabitLoader extends StatelessWidget {
  const HabitLoader({
    super.key,
    required this.iconAsset,
    required this.color,
    this.isDone = false,
  });

  final String iconAsset;
  final Color color;
  final bool isDone;

  static const double size = 36;
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: isDone ? 1 : 0),
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) => CustomPaint(
          painter: _RingPainter(progress: progress, color: color),
          child: child,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconAsset,
            width: _iconSize,
            height: _iconSize,
            colorFilter: ColorFilter.mode(
              readableOnWhite(color),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  /// Qué tanto del anillo se pinta, de 0 a 1.
  final double progress;
  final Color color;

  static const double _strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - _strokeWidth) / 2;

    final track = Paint()
      ..color = HabuuColors.black10
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    // Empieza arriba y avanza en el sentido del reloj.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
