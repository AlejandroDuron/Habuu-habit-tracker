import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/theme/tokens.dart';
import '../../models/home/habit_card_data.dart';
import 'add_icon.dart';
import 'friends_avatars.dart';
import 'habit_progress_bar.dart';

/// Tarjeta de un hábito o reto: ícono, título, progreso, amigos y acciones.
class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.data});

  final HabitCardData data;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      // Las tarjetas de reto miden 79px: 11px extra abajo para la barra.
      padding: EdgeInsets.fromLTRB(16, 16, 16, data.hasProgressBar ? 27 : 16),
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [habuuCardShadow],
      ),
      child: Row(
        children: [
          SvgPicture.asset(data.loaderIcon, width: 36, height: 36),
          const SizedBox(width: 12),
          Expanded(child: _TitleAndProgress(data: data)),
          const SizedBox(width: 12),
          if (data.hasFriends) ...[
            FriendsAvatars(avatars: data.avatars, extra: data.extraFriends),
            const SizedBox(width: 12),
          ],
          SvgPicture.asset(data.doneIcon, width: 36, height: 36),
          const SizedBox(width: 12),
          const AddIcon(),
        ],
      ),
    );

    if (!data.hasProgressBar) return card;

    return Stack(
      children: [
        card,
        Positioned(
          left: 31,
          right: 37,
          bottom: 10,
          height: 4,
          child: HabitProgressBar(fraction: data.progressFraction!),
        ),
      ],
    );
  }
}

class _TitleAndProgress extends StatelessWidget {
  const _TitleAndProgress({required this.data});

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
            data.progressLabel,
            style: HabuuText.captionSmMedium.copyWith(
              color: HabuuColors.black60,
            ),
          ),
        ],
      ),
    );
  }
}
