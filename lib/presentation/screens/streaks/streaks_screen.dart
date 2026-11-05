import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../providers/home_provider.dart';
import '../../providers/streaks_provider.dart';
import '../../providers/trophies_provider.dart';
import '../../widgets/streaks/calendar.dart';
import '../../widgets/streaks/streak_header.dart';
import '../../widgets/streaks/throphies_sumary.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  void initState() {
    super.initState();
    // Carga los datos al entrar en la pestaña.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreaksProvider>().loadStreak();
      context.read<TrophiesProvider>().loadTrophies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final streaks = context.watch<StreaksProvider>();
    final trophies = context.watch<TrophiesProvider>();
    final frogAwake = context.watch<HomeProvider>().frogAwake;

    if (streaks.isLoading && streaks.status == StreaksStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: HabuuColors.success700),
      );
    }

    // En caso de error, mostramos la pantalla con racha en 0 y sin días marcados.
    final latest = trophies.latestEarned;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreakHeader(
            streakCount: streaks.currentStreak,
            frogAwake: frogAwake,
            dayJustCompleted: streaks.dayJustCompleted,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Calendar(streakDays: streaks.streakDays),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TrophiesSummary(
              trophiesCount: trophies.earnedCount,
              latestTrophyImage: latest != null
                  ? _imageForKey(latest.trophy.key)
                  : 'assets/images/calendar/day_completed.png',
              latestTrophyLabel: latest?.trophy.name ?? '',
            ),
          ),
        ],
      ),
    );
  }
}

/// Mapeo de trophy_key → ruta del asset de imagen.
String _imageForKey(String? key) {
  const map = {
    'day_completed': 'assets/images/calendar/day_completed.png',
    'streak_7': 'assets/images/calendar/streak_7.png',
    'new_habits': 'assets/images/calendar/new_habits.png',
    'streak_14': 'assets/images/calendar/streak_14.png',
    'discipline': 'assets/images/calendar/discipline.png',
    'one_month': 'assets/images/calendar/one_month.png',
    'streak_300': 'assets/images/calendar/streak_300.png',
  };
  return map[key] ?? 'assets/images/calendar/day_completed.png';
}
