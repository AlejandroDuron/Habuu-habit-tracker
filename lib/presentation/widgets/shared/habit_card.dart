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

/// Tarjeta de hábito reutilizable: ícono con anillo · título · subtítulo ·
/// botón ⋮ con menú desplegable (Editar / Mover / Eliminar).
///
/// Cualquiera de los tres callbacks puede ser nulo; si los tres lo son, el
/// botón ⋮ no aparece.
class SimpleHabitCard extends StatelessWidget {
  const SimpleHabitCard({
    super.key,
    required this.data,
    this.onEdit,
    this.onDelete,
    this.onMove,
  });

  final SimpleHabitData data;

  /// Navega a la pantalla de edición.
  final VoidCallback? onEdit;

  /// Elimina el hábito (puede ser async externamente).
  final VoidCallback? onDelete;

  /// Abre el diálogo de reordenamiento.
  final VoidCallback? onMove;

  bool get _hasMenu => onEdit != null || onDelete != null || onMove != null;

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
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HabuuText.bodySmSemibold,
                ),
                const SizedBox(height: 2),
                Text(
                  data.progressLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HabuuText.captionSmMedium.copyWith(
                    color: HabuuColors.black60,
                  ),
                ),
              ],
            ),
          ),
          if (_hasMenu) ...[
            const SizedBox(width: 4),
            _MenuButton(
              habitName: data.title,
              onEdit: onEdit,
              onDelete: onDelete,
              onMove: onMove,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botón ⋮ con PopupMenuButton
// ---------------------------------------------------------------------------

enum _HabitAction { edit, move, delete }

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.habitName,
    this.onEdit,
    this.onDelete,
    this.onMove,
  });

  final String habitName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Opciones de $habitName',
      button: true,
      child: PopupMenuButton<_HabitAction>(
        icon: const Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: HabuuIconColors.black,
        ),
        // Abre el menú justo debajo del ícono ⋮
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        onSelected: (action) {
          switch (action) {
            case _HabitAction.edit:
              onEdit?.call();
            case _HabitAction.move:
              onMove?.call();
            case _HabitAction.delete:
              onDelete?.call();
          }
        },
        itemBuilder: (context) => [
          if (onEdit != null)
            const PopupMenuItem(
              value: _HabitAction.edit,
              child: _MenuItem(
                icon: Icons.edit_outlined,
                label: 'Editar',
              ),
            ),
          if (onMove != null)
            const PopupMenuItem(
              value: _HabitAction.move,
              child: _MenuItem(
                icon: Icons.open_with_rounded,
                label: 'Mover',
              ),
            ),
          if (onDelete != null)
            PopupMenuItem(
              value: _HabitAction.delete,
              child: _MenuItem(
                icon: Icons.delete_outline_rounded,
                label: 'Eliminar',
                color: HabuuColors.error500,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? HabuuColors.black100;
    return Row(
      children: [
        Icon(icon, size: 18, color: effectiveColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: HabuuText.bodySmMedium.copyWith(color: effectiveColor),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ícono con anillo de progreso
// ---------------------------------------------------------------------------

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
