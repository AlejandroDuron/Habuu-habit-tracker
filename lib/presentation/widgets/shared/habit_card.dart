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

  /// Color del contenedor circular cuando se usa [iconData].
  final Color? iconColor;
}

/// Tarjeta de hábito para la pantalla "Tus Hábitos":
/// ícono · título · subtítulo · botón de edición.
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
        borderRadius: BorderRadius.circular(HabuuRadius.sm),
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
                color: HabuuColors.black40,
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
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(data.iconData, size: 18, color: HabuuColors.black80),
    );
  }
}
