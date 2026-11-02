import 'package:flutter/material.dart';

import '../../models/home/habit_card_data.dart';
import 'habit_card.dart';
import 'section_header.dart';

/// Una sección del Home: título y su lista de tarjetas.
class HabitSection extends StatelessWidget {
  const HabitSection({
    super.key,
    required this.title,
    required this.items,
    this.onDone,
    this.expandedHabitId,
    this.expandedBuilder,
    this.headerGap = 4,
    this.itemGap = 16,
  });

  final String title;
  final List<HabitCardData> items;

  /// Se llama con la tarjeta cuyo botón de completar se tocó.
  final ValueChanged<HabitCardData>? onDone;

  /// Hábito que tiene su panel abierto, si hay alguno.
  final String? expandedHabitId;

  /// Arma el panel que se muestra debajo de la tarjeta abierta.
  final Widget Function(HabitCardData card)? expandedBuilder;

  /// Espacio entre el título y la primera tarjeta.
  final double headerGap;

  /// Espacio entre tarjetas.
  final double itemGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        SizedBox(height: headerGap),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: itemGap),
          _buildItem(items[i]),
        ],
      ],
    );
  }

  Widget _buildItem(HabitCardData card) {
    final expanded = card.habitId == expandedHabitId && expandedBuilder != null;

    return Column(
      key: ValueKey(card.habitId),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HabitCard(
          data: card,
          expanded: expanded,
          onDone: onDone == null ? null : () => onDone!(card),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: expanded ? expandedBuilder!(card) : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
