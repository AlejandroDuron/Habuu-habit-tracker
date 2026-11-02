import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../../utils/habit_style.dart';
import '../../models/home/habit_card_data.dart';
import 'habit_loader.dart';

/// Tarjeta de un hábito: ícono, título, meta y el botón de completar.
class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.data, this.onDone});

  final HabitCardData data;

  /// Se llama al tocar el botón de completar mientras sigue pendiente.
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [habuuCardShadow],
      ),
      child: Row(
        children: [
          HabitLoader(
            iconAsset: data.iconAsset,
            color: data.color,
            isDone: data.isDone,
          ),
          const SizedBox(width: 12),
          Expanded(child: _TitleAndSubtitle(data: data)),
          const SizedBox(width: 12),
          data.isDone
              ? _DoneMark(color: readableOnWhite(data.color))
              : _DoneButton(onPressed: onDone),
        ],
      ),
    );
  }
}

class _TitleAndSubtitle extends StatelessWidget {
  const _TitleAndSubtitle({required this.data});

  final HabitCardData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: HabuuText.bodySmSemibold),
          Text(
            data.subtitle,
            style: HabuuText.captionSmMedium.copyWith(
              color: HabuuColors.black60,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cheque relleno del color del hábito, para cuando ya se cumplió.
/// Mide lo mismo que el botón de completar para que la fila no se mueva.
class _DoneMark extends StatelessWidget {
  const _DoneMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Hábito cumplido',
      child: SizedBox.square(
        dimension: 36,
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: HabuuColors.white100,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón para marcar el hábito como cumplido.
class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Marcar como cumplido',
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: SvgPicture.asset(HomeAssets.done, width: 36, height: 36),
      ),
    );
  }
}
