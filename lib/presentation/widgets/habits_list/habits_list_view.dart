import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_log.dart';
import '../../providers/habits_provider.dart';
import '../habits/habit_icon_picker.dart';
import '../shared/habit_card.dart';

/// Lista scrolleable de hábitos con secciones opcionales.
///
/// Cuando [chipFilter] es [HabitChipFilter.all], los hábitos se agrupan en
/// tres secciones: pendientes (sin log), Completados y Omitidos.
/// Con cualquier otro filtro se muestra la lista plana sin encabezados.
///
/// Debe vivir dentro de un widget con altura acotada (Expanded, SizedBox, etc.)
class HabitsListView extends StatelessWidget {
  const HabitsListView({
    super.key,
    required this.habits,
    required this.onEdit,
    this.onDelete,
    this.onMove,
    this.isLoading = false,
    this.logStatuses = const {},
    this.chipFilter = HabitChipFilter.all,
  });

  final List<Habit> habits;
  final ValueChanged<Habit> onEdit;
  final ValueChanged<Habit>? onDelete;
  final ValueChanged<Habit>? onMove;
  final bool isLoading;

  /// Estado de log del día para cada hábito (id → LogStatus).
  final Map<String, LogStatus> logStatuses;

  /// Filtro de chip activo; determina si se muestran secciones o lista plana.
  final HabitChipFilter chipFilter;

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

    // Con filtro activo (no "Todo") → lista plana sin encabezados.
    if (chipFilter != HabitChipFilter.all) {
      return _FlatList(
        habits: habits,
        onEdit: onEdit,
        onDelete: onDelete,
        onMove: onMove,
      );
    }

    // Filtro "Todo": agrupar en Pendientes / Completados / Omitidos.
    final pending = <Habit>[];
    final done = <Habit>[];
    final skipped = <Habit>[];

    for (final h in habits) {
      final status = logStatuses[h.id];
      if (status == LogStatus.done) {
        done.add(h);
      } else if (status == LogStatus.skipped) {
        skipped.add(h);
      } else {
        pending.add(h);
      }
    }

    return CustomScrollView(
      scrollCacheExtent: const ScrollCacheExtent.pixels(800),
      slivers: [
        // ── Pendientes (sin encabezado, son los hábitos normales) ──────────
        _HabitSliver(
          habits: pending,
          onEdit: onEdit,
          onDelete: onDelete,
          onMove: onMove,
          bottomPadding: (done.isEmpty && skipped.isEmpty) ? 0 : 16,
        ),

        // ── Completados ────────────────────────────────────────────────────
        if (done.isNotEmpty) ...[
          _SectionHeader(label: 'Completados'),
          _HabitSliver(
            habits: done,
            onEdit: onEdit,
            onDelete: onDelete,
            onMove: onMove,
            bottomPadding: skipped.isEmpty ? 0 : 16,
          ),
        ],

        // ── Omitidos ───────────────────────────────────────────────────────
        if (skipped.isNotEmpty) ...[
          _SectionHeader(label: 'Omitidos'),
          _HabitSliver(
            habits: skipped,
            onEdit: onEdit,
            onDelete: onDelete,
            onMove: onMove,
            bottomPadding: 0,
          ),
        ],

        // Espacio al final para que la última tarjeta no quede pegada al FAB.
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── Lista plana (sin secciones) ─────────────────────────────────────────────

class _FlatList extends StatelessWidget {
  const _FlatList({
    required this.habits,
    required this.onEdit,
    this.onDelete,
    this.onMove,
  });

  final List<Habit> habits;
  final ValueChanged<Habit> onEdit;
  final ValueChanged<Habit>? onDelete;
  final ValueChanged<Habit>? onMove;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollCacheExtent: const ScrollCacheExtent.pixels(800),
      slivers: [
        _HabitSliver(
          habits: habits,
          onEdit: onEdit,
          onDelete: onDelete,
          onMove: onMove,
          bottomPadding: 0,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── Encabezado de sección ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
        child: Text(
          label,
          style: HabuuText.captionMdMedium.copyWith(
            color: HabuuColors.black60,
          ),
        ),
      ),
    );
  }
}

// ── Sliver reutilizable con las tarjetas de hábitos ─────────────────────────

class _HabitSliver extends StatelessWidget {
  const _HabitSliver({
    required this.habits,
    required this.onEdit,
    this.onDelete,
    this.onMove,
    this.bottomPadding = 0,
  });

  final List<Habit> habits;
  final ValueChanged<Habit> onEdit;
  final ValueChanged<Habit>? onDelete;
  final ValueChanged<Habit>? onMove;

  /// Espacio extra debajo del último ítem (antes del siguiente encabezado).
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
      sliver: SliverList.builder(
        itemCount: habits.length,
        itemBuilder: (context, i) {
          final habit = habits[i];
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < habits.length - 1 ? 12 : 0,
            ),
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
    );
  }
}
