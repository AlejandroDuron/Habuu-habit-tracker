import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../widgets/home/habit_section.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/today_card.dart';
import 'home_mock_data.dart';

/// Pantalla Home de Habuu
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [HabuuColors.primary50, HabuuColors.success200],
            stops: [0.21635, 1.0],
          ),
        ),
        // El contenido termina antes de la navbar y no se ve detrás de ella.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(35, 76, 35, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              HomeHeader(),
              SizedBox(height: 23),
              TodayCard(days: HomeMockData.days),
              SizedBox(height: 23),
              HabitSection(
                title: 'Retos',
                items: HomeMockData.challenges,
                headerGap: 19,
              ),
              SizedBox(height: 19),
              HabitSection(title: 'Hábitos', items: HomeMockData.habits),
            ],
          ),
        ),
      ),
    );
  }
}
