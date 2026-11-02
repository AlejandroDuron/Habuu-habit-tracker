import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/habits_list/category_chips.dart';
import '../../widgets/habits_list/habits_list_header.dart';
import '../../widgets/habits_list/habits_list_view.dart';
import '../../widgets/habits_list/period_segment.dart';
import '../../widgets/shared/add_habit_fab.dart';
import 'habit_form_screen.dart';
import 'habits_screen.dart';

const _periods = ['Hoy', 'Semana', 'Todo'];

/// Chips de filtrado en una sola fila:
/// [0] Todo · [1] Frecuente · [2] Fugaz · [3] Salud · [4] Hogar · [5] Universidad
const _chips = ['Todo', 'Frecuente', 'Fugaz', 'Salud', 'Hogar', 'Universidad'];

/// Pantalla "Tus Hábitos": lista filtrable por período, tipo y categoría.
class HabitsListScreen extends StatefulWidget {
  const HabitsListScreen({super.key});

  @override
  State<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends State<HabitsListScreen> {
  int _periodIndex = 0;

  /// Índice del chip activo (ver constante [_chips]).
  int _chipIndex = 0;

  // ── Navegación ────────────────────────────────────────────────────────────

  void _openEdit(Habit habit) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
    );
  }

  void _openNew() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const HabitFormScreen()),
    );
  }

  void _openAllHabits() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HabitsScreen(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  // ── Acciones de tarjeta ───────────────────────────────────────────────────

  Future<void> _deleteHabit(Habit habit) async {
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

    if (confirmed != true || !mounted) return;

    final provider = context.read<HabitsProvider>();
    final ok = await provider.deleteHabit(habit.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Hábito eliminado' : provider.errorMessage ?? 'Algo salió mal',
        ),
      ),
    );
  }

  Future<void> _moveHabit(Habit habit) async {
    final provider = context.read<HabitsProvider>();
    final habits = provider.habits;
    final currentIndex = habits.indexWhere((h) => h.id == habit.id);
    if (currentIndex == -1) return;

    final positions =
        List.generate(habits.length, (i) => i)
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

    if (targetIndex == null || !mounted) return;
    provider.reorderHabits(habit.type, currentIndex, targetIndex);
  }

  // ── Filtrado ───────────────────────────────────────────────────────────────

  List<Habit> _filtered(List<Habit> all) {
    return switch (_chipIndex) {
      1 => all.where((h) => h.type == HabitType.frecuente).toList(),
      2 => all.where((h) => h.type == HabitType.fugaz).toList(),
      3 => all.where((h) => h.category == HabitCategory.salud).toList(),
      4 => all.where((h) => h.category == HabitCategory.hogar).toList(),
      5 => all.where((h) => h.category == HabitCategory.universidad).toList(),
      _ => all, // 0 = Todo
    };
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();

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
                child: HabitsListHeader(onMore: _openAllHabits),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PeriodSegment(
                  labels: _periods,
                  selected: _periodIndex,
                  onChanged: (i) => setState(() => _periodIndex = i),
                ),
              ),
              const SizedBox(height: 16),
              CategoryChips(
                categories: _chips,
                selected: _chipIndex,
                onChanged: (i) => setState(() => _chipIndex = i),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: HabitsListView(
                  habits: _filtered(provider.habits),
                  isLoading: provider.isLoading,
                  onEdit: _openEdit,
                  onDelete: _deleteHabit,
                  onMove: _moveHabit,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AddHabitFab(onPressed: _openNew),
    );
  }
}
