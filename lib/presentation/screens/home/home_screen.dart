import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../models/home/habit_card_data.dart';
import '../../providers/home_provider.dart';
import '../../providers/trophies_provider.dart';
import '../../widgets/home/evidence_panel.dart';
import '../../widgets/home/habit_section.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/today_card.dart';
import '../../widgets/thophies/trophy_earned_toast.dart';
import '../habits/habits_screen.dart';
import 'home_mock_data.dart';

/// Pantalla Home de Habuu
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Hábito con el panel de la foto abierto. Solo puede haber uno.
  String? _expandedHabitId;

  @override
  void initState() {
    super.initState();
    // Se espera al primer frame para no avisar cambios mientras se dibuja.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeProvider>().load();
    });
  }

  /// Abre el panel de la foto de ese hábito, o lo cierra si ya estaba abierto.
  void _togglePanel(HabitCardData card) {
    setState(() {
      _expandedHabitId = _expandedHabitId == card.habitId ? null : card.habitId;
    });
  }

  /// Abre la lista con todos los hábitos. Al volver se recarga el Home,
  /// por si se editó o se borró alguno.
  Future<void> _openAllHabits() async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const HabitsScreen()));
    if (mounted) await context.read<HomeProvider>().load();
  }

  /// Marca el hábito como cumplido, con foto o sin ella, y cierra el panel.
  Future<void> _complete(HabitCardData card, {Uint8List? photo}) async {
    final error = await context.read<HomeProvider>().markDone(
      card.habitId,
      photo: photo,
    );
    if (!mounted) return;

    if (error == null) {
      setState(() => _expandedHabitId = null);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final trophies = context.watch<TrophiesProvider>();

    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
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
                    _HabitsContent(
                      home: home,
                      onDone: _togglePanel,
                      onShowMore: _openAllHabits,
                      expandedHabitId: _expandedHabitId,
                      panelBuilder: (card) => EvidencePanel(
                        onSave: (photo) => _complete(card, photo: photo),
                        onSkip: () => _complete(card),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Toast de trofeo ganado (se muestra encima de todo)
          if (trophies.newlyEarned.isNotEmpty)
            TrophyEarnedToast(
              key: ValueKey(trophies.newlyEarned.first.earnedAt),
              trophy: trophies.newlyEarned.first,
              onDismissed: () => trophies.clearNewlyEarned(),
            ),
        ],
      ),
    );
  }
}

/// La sección de hábitos según cómo va la carga.
class _HabitsContent extends StatelessWidget {
  const _HabitsContent({
    required this.home,
    required this.onDone,
    required this.onShowMore,
    required this.expandedHabitId,
    required this.panelBuilder,
  });

  final HomeProvider home;
  final ValueChanged<HabitCardData> onDone;
  final VoidCallback onShowMore;
  final String? expandedHabitId;
  final Widget Function(HabitCardData card) panelBuilder;

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
        onShowMore: onShowMore,
        expandedHabitId: expandedHabitId,
        expandedBuilder: panelBuilder,
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
