import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../models/home/calendar_day.dart';
import '../../models/home/habit_card_data.dart';
import '../../providers/home_provider.dart';
import '../../providers/trophies_provider.dart';
import '../../providers/verification_settings_provider.dart';
import '../../widgets/home/evidence_panel.dart';
import '../../widgets/home/evidence_photo_panel.dart';
import '../../widgets/home/frog_mood_builder.dart';
import '../../widgets/home/habit_section.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/today_card.dart';
import '../../widgets/shared/verification_dialogs.dart';
import '../../widgets/thophies/trophy_earned_toast.dart';

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
    final previous = _expandedHabitId;
    if (previous != null) {
      context.read<HomeProvider>().dismissEvidence(previous);
    }
    setState(() {
      _expandedHabitId = previous == card.habitId ? null : card.habitId;
    });
  }

  void _closePanel() {
    final id = _expandedHabitId;
    if (id == null) return;
    context.read<HomeProvider>().dismissEvidence(id);
    setState(() => _expandedHabitId = null);
  }

  /// Marca el hábito como omitido y cierra el panel.
  Future<void> _skip(HabitCardData card) async {
    final error = await context.read<HomeProvider>().markSkipped(card.habitId);
    if (!mounted) return;

    if (error == null) {
      _closePanel();
    } else {
      _showError(error);
    }
  }

  /// Marca el hábito como cumplido, con foto o sin ella, y cierra el panel.
  Future<void> _complete(HabitCardData card, {Uint8List? photo}) async {
    final error = await context.read<HomeProvider>().markDone(
      card.habitId,
      photo: photo,
    );
    if (!mounted) return;

    if (error == null) {
      _closePanel();
    } else {
      _showError(error);
    }
  }

  /// Sube la foto y, si el usuario lo aceptó, la manda a revisar. La primera
  /// vez se le pregunta.
  Future<void> _save(HabitCardData card, Uint8List photo) async {
    final settings = context.read<VerificationSettingsProvider>();
    final home = context.read<HomeProvider>();

    var verify = await settings.current();
    if (!mounted) return;
    if (verify == null) {
      verify = await showVerificationConsentDialog(context);
      if (!mounted) return;
      await settings.setEnabled(verify);
      if (!mounted) return;
    }

    if (!verify) return _complete(card, photo: photo);

    final error = await home.submitEvidence(card.habitId, photo);
    if (!mounted) return;
    if (error != null) _showError(error);
  }

  Future<void> _saveWithoutVerification(HabitCardData card) async {
    final error = await context.read<HomeProvider>().saveWithoutVerification(
      card.habitId,
    );
    if (!mounted) return;

    if (error == null) {
      _closePanel();
    } else {
      _showError(error);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Genera la tira de días del calendario: 4 antes de hoy, hoy, 4 después.
  /// Hoy se marca con [isToday] y, si [frogAwake] es true, con [hasFrog].
  List<CalendarDay> _buildDays(bool frogAwake) {
    final now = DateTime.now();
    return List.generate(9, (i) {
      final date = now.subtract(Duration(days: 4 - i));
      final isToday = i == 4;
      return CalendarDay(
        day: '${date.day}',
        isToday: isToday,
        hasFrog: isToday && frogAwake,
      );
    });
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
                    FrogMoodBuilder(
                      awake: home.frogAwake,
                      lastDoneAt: home.lastDoneAt,
                      builder: (context, mood) => TodayCard(
                        days: _buildDays(home.frogAwake),
                        frogMood: mood,
                      ),
                    ),
                    const SizedBox(height: 23),
                    _HabitsContent(
                      home: home,
                      onDone: _togglePanel,
                      expandedHabitId: _expandedHabitId,
                      panelBuilder: (card) {
                        final check = home.evidenceCheckFor(card.habitId);
                        // Ya cumplido y sin una revisión en curso: solo se
                        // ve la foto.
                        if (card.isDone && check == null) {
                          return EvidencePhotoPanel(
                            loadPhoto: () =>
                                home.evidencePhotoFor(card.habitId),
                            onClose: _closePanel,
                          );
                        }
                        return EvidencePanel(
                          allowSkip: card.allowSkip,
                          check: check,
                          onSave: (photo) => _save(card, photo),
                          onSkip: () => _skip(card),
                          onRetry: () => home.retryVerification(card.habitId),
                          onSaveAnyway: () => _saveWithoutVerification(card),
                          onFinish: _closePanel,
                        );
                      },
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
    required this.expandedHabitId,
    required this.panelBuilder,
  });

  final HomeProvider home;
  final ValueChanged<HabitCardData> onDone;
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
