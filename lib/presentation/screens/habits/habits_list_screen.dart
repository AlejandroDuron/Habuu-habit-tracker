import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
import '../../../utils/dates.dart';
import '../../models/habits_list/weekly_habit_data.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/habits_list/habit_filter_chips.dart';
import '../../widgets/habits_list/habits_list_header.dart';
import '../../widgets/habits_list/habits_list_view.dart';
import '../../widgets/habits_list/period_segment.dart';
import '../../widgets/habits_list/weekly_habits_list_view.dart';
import '../../widgets/shared/add_habit_fab.dart';
import 'habit_form_screen.dart';

const _periods = ['Hoy', 'Semana', 'Todo'];

/// Mapeo de índice de segmento → [HabitPeriodFilter].
const _periodFilters = [
  HabitPeriodFilter.today,
  HabitPeriodFilter.week,
  HabitPeriodFilter.all,
];



/// Pantalla "Tus Hábitos": lista filtrable por período, tipo y categoría.
///
/// La lógica de filtrado vive en [HabitsProvider.filteredHabits].
/// Esta pantalla solo refleja y comunica los cambios de filtro.
class HabitsListScreen extends StatelessWidget {
  const HabitsListScreen({super.key});

  // ── Navegación ────────────────────────────────────────────────────────────

  void _openEdit(BuildContext context, Habit habit) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
    );
  }

  void _openNew(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const HabitFormScreen()),
    );
  }

  // ── Acciones de tarjeta ───────────────────────────────────────────────────

  Future<void> _deleteHabit(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar hábito?'),
        content: Text('Se eliminará "${habit.name}" de forma permanente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: HabuuColors.error500),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<HabitsProvider>();
    final ok = await provider.deleteHabit(habit.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Hábito eliminado' : provider.errorMessage ?? 'Algo salió mal',
        ),
      ),
    );
  }

  Future<void> _moveHabit(BuildContext context, Habit habit) async {
    final provider = context.read<HabitsProvider>();
    final habits =
        provider.habits.where((h) => h.type == habit.type).toList();
    final currentIndex = habits.indexWhere((h) => h.id == habit.id);
    if (currentIndex == -1) return;

    final positions = List.generate(habits.length, (i) => i)
        .where((i) => i != currentIndex)
        .toList();

    if (positions.isEmpty) return;

    final targetIndex = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Mover "${habit.name}"'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elige la nueva posición:',
                style: HabuuText.captionMdMedium.copyWith(
                  color: HabuuColors.black60,
                ),
              ),
              const SizedBox(height: 8),
              ...positions.map(
                (i) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: HabuuColors.primary500,
                    child: Text(
                      '${i + 1}',
                      style: HabuuText.captionSmMedium.copyWith(
                        color: HabuuColors.white100,
                      ),
                    ),
                  ),
                  title: Text(
                    habits[i].name,
                    style: HabuuText.bodySmMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.pop(ctx, i),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (targetIndex == null || !context.mounted) return;
    provider.reorderHabits(habit.type, currentIndex, targetIndex);
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  Widget _buildWeekly(BuildContext context, HabitsProvider provider) {
    final habits = provider.filteredHabits;
    final weekStart = weekStartOf(DateTime.now());

    return WeeklyHabitsListView(
      isLoading: provider.isLoading,
      habits: [
        for (final habit in habits)
          WeeklyHabitData.fromHabit(
            habit,
            provider.weekStatusesFor(habit.id),
            weekStart: weekStart,
          ),
      ],
      onTap: (i) => _openEdit(context, habits[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Leemos el provider una sola vez por build; los cambios de filtro
    // llaman a notifyListeners() que dispara un rebuild automático.
    final provider = context.watch<HabitsProvider>();

    // Índices actuales para los widgets de filtro.
    final periodIndex = _periodFilters.indexOf(provider.periodFilter);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: HabuuGradients.pond),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: HabitsListHeader(),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PeriodSegment(
                  labels: _periods,
                  selected: periodIndex < 0 ? 0 : periodIndex,
                  onChanged: (i) =>
                      provider.setPeriodFilter(_periodFilters[i]),
                ),
              ),

              const SizedBox(height: 20),
              HabitFilterChips(
                chipFilter: provider.chipFilter,
                categoryFilter: provider.categoryFilter,
                categories: provider.availableCategories,
                onTypeChanged: provider.setChipFilter,
                onCategoryChanged: provider.setCategoryFilter,
                onReset: provider.resetFilters,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              Expanded(
                child: provider.periodFilter == HabitPeriodFilter.week
                    ? _buildWeekly(context, provider)
                    : HabitsListView(
                        habits: provider.filteredHabits,
                        isLoading: provider.isLoading,
                        onEdit: (habit) => _openEdit(context, habit),
                        onDelete: (habit) => _deleteHabit(context, habit),
                        onMove: (habit) => _moveHabit(context, habit),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AddHabitFab(
        onPressed: () => _openNew(context),
      ),
    );
  }
}
