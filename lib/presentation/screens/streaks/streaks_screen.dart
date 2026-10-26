import 'package:flutter/material.dart';
import '../../widgets/streaks/streak_header.dart';
import '../../widgets/streaks/calendar.dart';
import '../../widgets/streaks/throphies_sumary.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StreakHeader(streakCount: 5),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Calendar(
              streakDays: {
                for (var i = 0; i < 5; i++)
                  DateTime.now().subtract(Duration(days: i)),
              },
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: TrophiesSummary(trophiesCount: 3),
          ),
        ],
      ),
    );
  }
}