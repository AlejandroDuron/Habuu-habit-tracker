import 'package:flutter/material.dart';
import '../../widgets/streaks/streak_header.dart';
import '../../widgets/streaks/calendar.dart';
import '../../widgets/streaks/throphies_sumary.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreakHeader(streakCount: 5),
            SizedBox(height: 16),
            Calendar(),
            SizedBox(height: 16),
            TrophiesSummary(trophiesCount: 3),
          ],
        ),
      ),
    );
  }
}
