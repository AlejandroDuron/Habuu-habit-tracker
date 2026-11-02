import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../models/home/habit_card_data.dart';
import '../../providers/home_provider.dart';
import '../../widgets/home/habit_section.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/today_card.dart';
import 'home_mock_data.dart';

/// Pantalla Home de Habuu
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Se espera al primer frame para no avisar cambios mientras se dibuja.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeProvider>().load();
    });
  }

  Future<void> _markDone(HabitCardData card) async {
    final error = await context.read<HomeProvider>().markDone(card.habitId);
    if (error == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

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
        child: RefreshIndicator(
          onRefresh: home.load,
          // El contenido termina antes de la navbar y no se ve detrás de ella.
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(35, 76, 35, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HomeHeader(),
                const SizedBox(height: 23),
                TodayCard(days: HomeMockData.days, frogAwake: home.frogAwake),
                const SizedBox(height: 23),
                _HabitsContent(home: home, onDone: _markDone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La sección de hábitos según cómo va la carga.
class _HabitsContent extends StatelessWidget {
  const _HabitsContent({required this.home, required this.onDone});

  final HomeProvider home;
  final ValueChanged<HabitCardData> onDone;

  @override
  Widget build(BuildContext context) {
    return switch (home.status) {
      HomeStatus.loading => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      HomeStatus.signedOut => const _HomeMessage(
        text: 'Inicia sesión para ver tus hábitos',
      ),
      HomeStatus.error => _HomeMessage(
        text: home.errorMessage ?? 'No se pudieron cargar tus hábitos',
        actionLabel: 'Reintentar',
        onAction: home.load,
      ),
      HomeStatus.ready when home.habits.isEmpty => const _HomeMessage(
        text: 'No tienes hábitos para hoy',
      ),
      HomeStatus.ready => HabitSection(
        title: 'Hábitos',
        items: home.habits.map(HabitCardData.fromTodayHabit).toList(),
        onDone: onDone,
      ),
    };
  }
}

/// Mensaje centrado, con un botón opcional.
class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: HabuuText.subtitleMdBold.copyWith(
              color: HabuuColors.success800,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
