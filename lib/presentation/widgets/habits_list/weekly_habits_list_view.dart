import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../models/habits_list/weekly_habit_data.dart';
import 'weekly_habit_card.dart';

class WeeklyHabitsListView extends StatelessWidget {
  const WeeklyHabitsListView({
    super.key,
    required this.habits,
    required this.onTap,
    this.isLoading = false,
  });

  final List<WeeklyHabitData> habits;
  final ValueChanged<int> onTap;
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
          'No tienes hábitos esta semana',
          style: HabuuText.bodySmMedium.copyWith(color: HabuuColors.black60),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 104),
      itemCount: habits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (_, i) =>
          WeeklyHabitCard(data: habits[i], onTap: () => onTap(i)),
    );
  }
}
