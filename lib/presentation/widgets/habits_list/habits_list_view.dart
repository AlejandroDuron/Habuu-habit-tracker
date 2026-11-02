import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
import '../habits/habit_icon_picker.dart';
import '../shared/habit_card.dart';

/// Lista scrolleable de hábitos con etiqueta "Omitidos" al final.
/// Debe vivir dentro de un widget con altura acotada (Expanded, SizedBox, etc.)
class HabitsListView extends StatelessWidget {
  const HabitsListView({
    super.key,
    required this.habits,
    required this.onEdit,
    this.onDelete,
    this.onMove,
    this.isLoading = false,
  });

  final List<Habit> habits;

  /// Abre la pantalla de edición para el hábito seleccionado.
  final ValueChanged<Habit> onEdit;

  /// Elimina el hábito seleccionado. Si es null, la opción no aparece.
  final ValueChanged<Habit>? onDelete;

  /// Abre el diálogo de reordenamiento. Si es null, la opción no aparece.
  final ValueChanged<Habit>? onMove;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: HabuuColors.primary500),
      );
    }

    if (habits.isEmpty) {
      return Center(
        child: Text(
          'Aún no tienes hábitos',
          style: HabuuText.bodySmMedium.copyWith(color: HabuuColors.black60),
        ),
      );
    }

    // CustomScrollView une la lista y el footer "Omitidos" en un solo scroll,
    // sin necesidad de anidar Column + Expanded adentro de otro Expanded.
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          sliver: SliverList.separated(
            itemCount: habits.length,
            separatorBuilder: (context, _) => const SizedBox(height: 12),
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
                onDelete: onDelete == null ? null : () => onDelete!(habit),
                onMove: onMove == null ? null : () => onMove!(habit),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Text(
              'Omitidos',
              style: HabuuText.captionMdMedium.copyWith(
                color: HabuuColors.black60,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
