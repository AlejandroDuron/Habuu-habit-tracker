import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/tokens.dart';

/// Datos que necesita [SimpleHabitCard] para dibujarse.
/// Provee [iconData] cuando el ícono viene del picker de Material,
/// o [iconAsset] cuando viene de un SVG. Uno de los dos debe ser no nulo.
class SimpleHabitData {
  const SimpleHabitData({
    required this.title,
    required this.progressLabel,
    this.iconData,
    this.iconAsset,
    this.iconColor,
    this.progress = 0,
  }) : assert(
          iconData != null || iconAsset != null,
          'Provee iconData o iconAsset',
        );

  final String title;
  final String progressLabel;

  /// Ícono de Material (viene del HabitIconPicker).
  final IconData? iconData;

  /// Ruta de un SVG (viene de HomeAssets).
  final String? iconAsset;

  /// Color del anillo y del ícono cuando se usa [iconData].
  final Color? iconColor;

  /// Avance del hábito de 0 a 1 (arco del anillo).
  final double progress;
}

/// Tarjeta de hábito para la pantalla "Tus Hábitos":
/// ícono con anillo de progreso · título · subtítulo · botón de edición.
class SimpleHabitCard extends StatelessWidget {
  const SimpleHabitCard({super.key, required this.data, this.onEdit});

  final SimpleHabitData data;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [habuuCardShadow],
      ),
      child: Row(
        children: [
          _HabitIcon(data: data),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: HabuuText.bodySmSemibold),
                const SizedBox(height: 2),
                Text(
                  data.progressLabel,
                  style: HabuuText.captionSmMedium.copyWith(
                    color: HabuuColors.black60,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: Semantics(
              label: 'Editar ${data.title}',
              button: true,
              child: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: HabuuIconColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitIcon extends StatelessWidget {
  const _HabitIcon({required this.data});

  final SimpleHabitData data;

  @override
  Widget build(BuildContext context) {
    if (data.iconAsset != null) {
      return SvgPicture.asset(data.iconAsset!, width: 36, height: 36);
    }

    final color = data.iconColor ?? HabuuColors.primary500;
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(
        painter: _RingPainter(
          progress: data.progress,
          color: color,
          track: HabuuColors.grey150,
        ),
        child: Center(
          child: Icon(data.iconData, size: 18, color: color),
        ),
      ),
    );
  }
}

/// Anillo de progreso: pista gris completa y arco de color encima.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  static const double _stroke = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);

    // Pista
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = track,
    );

    // Arco de avance (empieza arriba)
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}