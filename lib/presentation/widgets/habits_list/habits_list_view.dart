import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

    // CustomScrollView con SliverList.builder: Flutter construye cada tarjeta
    // solo cuando entra al viewport (lazy rendering). cacheExtent amplía la
    // zona de precarga un poco más allá de lo visible para que el scroll
    // sea fluido incluso con listas largas.
    return CustomScrollView(
      // Precarga items equivalentes a ~2 pantallas fuera del viewport visible.
      scrollCacheExtent: const ScrollCacheExtent.pixels(800),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          sliver: SliverList.builder(
            itemCount: habits.length,
            itemBuilder: (context, i) {
              final habit = habits[i];
              return Padding(
                // Separador entre tarjetas sin necesidad de un sliver extra.
                padding: EdgeInsets.only(bottom: i < habits.length - 1 ? 12 : 0),
                child: SimpleHabitCard(
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
                ),
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
