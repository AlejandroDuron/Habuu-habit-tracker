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

const _periods = ['Hoy', 'Semana', 'Todo'];
const _categories = ['Todo', 'Salud', 'Hogar', 'Universidad'];

/// Pantalla "Tus Hábitos": lista filtrable por período y categoría.
class HabitsListScreen extends StatefulWidget {
  const HabitsListScreen({super.key});

  @override
  State<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends State<HabitsListScreen> {
  int _periodIndex = 0;
  int _categoryIndex = 0;

  void _openEdit(Habit habit) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => HabitFormScreen(habit: habit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsProvider>().habits;

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
                child: const HabitsListHeader(),
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
                categories: _categories,
                selected: _categoryIndex,
                onChanged: (i) => setState(() => _categoryIndex = i),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: HabitsListView(
                  habits: habits,
                  onEdit: _openEdit,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AddHabitFab(onPressed: () {}),
    );
  }
}
