
import 'package:flutter/material.dart';

import '../../widgets/thophies/trophy_card.dart';

class TrophiesScreen extends StatelessWidget {
  const TrophiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis trofeos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TrophyCard(
                title: 'Trofeo de Oro',
                description:
                    'Has completado 30 días consecutivos de hábitos.',
                imagePath: 'assets/images/dragonfly_left.png',
              ),
              SizedBox(height: 16),
              TrophyCard(
                title: 'Trofeo de Plata',
                description:
                    'Has completado 15 días consecutivos de hábitos.',
                imagePath: 'assets/images/dragonfly_left.png',
              ),
              SizedBox(height: 16),
              TrophyCard(
                title: 'Trofeo de Bronce',
                description:
                    'Has completado 7 días consecutivos de hábitos.',
                imagePath: 'assets/images/dragonfly_left.png',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
