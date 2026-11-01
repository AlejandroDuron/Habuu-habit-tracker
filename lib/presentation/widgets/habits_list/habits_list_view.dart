import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
import '../habits/habit_icon_picker.dart';
import '../shared/habit_card.dart';

/// Lista scrolleable de hábitos con etiqueta "Omitidos" al final.
class HabitsListView extends StatelessWidget {
  const HabitsListView({
    super.key,
    required this.habits,
    required this.onEdit,
  });

  final List<Habit> habits;

  /// Se llama con el hábito seleccionado al tocar el lápiz.
  final ValueChanged<Habit> onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            itemCount: habits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final habit = habits[i];
              return SimpleHabitCard(
                data: SimpleHabitData(
                  title: habit.name,
                  progressLabel:
                      '${habit.goalPerDay} ${habit.goalPerDay == 1 ? 'vez' : 'veces'} al día',
                  iconData: habitIconFor(habit.iconIndex),
                  iconColor: Color(habit.colorValue),
                ),
                onEdit: () => onEdit(habit),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Text(
            'Omitidos',
            style: HabuuText.captionMdMedium.copyWith(
              color: HabuuColors.black60,
            ),
          ),
        ),
      ],
    );
  }
}
