import 'package:flutter/material.dart';
import '../../models/home/habit_card_data.dart';
import 'habit_card.dart';
import 'section_header.dart';

/// Una sección del Home (Retos, Hábitos...): título y su lista de tarjetas.
class HabitSection extends StatelessWidget {
  const HabitSection({
    super.key,
    required this.title,
    required this.items,
    this.headerGap = 4,
    this.itemGap = 16,
  });

  final String title;
  final List<HabitCardData> items;

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
          HabitCard(data: items[i]),
        ],
      ],
    );
  }
}
