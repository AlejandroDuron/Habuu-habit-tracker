import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../shared/animated_frog.dart';

/// Cuánto dura cada fase temporal antes de volver a descanso.
const _kCelebrationDuration = Duration(seconds: 10);
const _kMilestoneDuration = Duration(seconds: 10);

/// Racha mínima para mostrar la animación de hito (one_month.png).
const _kMilestoneStreak = 7;

/// Estados de Froggy en la pantalla de Rachas.
///
/// El orden refleja la prioridad: milestone > hopping > resting > sleeping.
enum _FrogState {
  /// Sin racha ni hábitos completados hoy → duerme.
  sleeping,

  /// Tiene racha o completó al menos un hábito → descansa despierta.
  resting,

  /// Acaba de completar un hábito → salta (igual que celebrating en el Home).
  hopping,

  /// Racha ≥ 7 días recién detectada → muestra one_month.png saltando.
  milestone,
}

/// Header de la pantalla de Rachas.
///
/// Usa la misma lógica de estados que [PondHero] en el Home:
/// - Sin racha ni hábito hoy  → Froggy duerme (breathe).
/// - Completó un hábito hoy   → salta 10 s (hop) y luego descansa (breathe).
/// - Racha ≥ 7 días           → muestra one_month.png saltando 10 s y luego
///                              vuelve al descanso.
///
/// Si se cumplen varias condiciones a la vez, [milestone] tiene prioridad
/// sobre [hopping]; ambas vuelven a [resting] tras su temporizador.
class StreakHeader extends StatefulWidget {
  const StreakHeader({
    super.key,
    required this.streakCount,
    this.frogAwake = false,
    this.dayJustCompleted = false,
  });

  final int streakCount;

  /// true si el usuario completó al menos un hábito hoy.
  final bool frogAwake;

  /// true cuando el día acaba de completarse (señal explícita para animar).
  final bool dayJustCompleted;

  @override
  State<StreakHeader> createState() => _StreakHeaderState();
}

class _StreakHeaderState extends State<StreakHeader> {
  _FrogState _state = _FrogState.sleeping;
  Timer? _timer;

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _applyState(widget.frogAwake, widget.streakCount, initial: true);
  }

  @override
  void didUpdateWidget(covariant StreakHeader old) {
    super.didUpdateWidget(old);

    final awakeBecameTrue = !old.frogAwake && widget.frogAwake;
    final dayCompleted = !old.dayJustCompleted && widget.dayJustCompleted;
    final streakHitMilestone =
        old.streakCount < _kMilestoneStreak &&
        widget.streakCount >= _kMilestoneStreak;

    // Milestone tiene prioridad: se dispara si la racha acaba de cruzar
    // el umbral de 7 días, independientemente de si frogAwake cambió.
    if (streakHitMilestone) {
      _startMilestone();
      return;
    }

    // El día se completó explícitamente (señal del provider) → salta.
    if (dayCompleted) {
      _startHopping();
      return;
    }

    // Froggy despertó en el Home (completó el primer hábito del día) → salta.
    if (awakeBecameTrue) {
      _startHopping();
      return;
    }

    // Si pierde la racha y no tiene hábitos → vuelve a dormir.
    if (!widget.frogAwake && widget.streakCount == 0) {
      _cancelTimer();
      if (mounted) setState(() => _state = _FrogState.sleeping);
    }
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  // ── Transiciones de estado ────────────────────────────────────────────────

  /// Decide el estado inicial sin iniciar temporizadores innecesarios.
  void _applyState(bool awake, int streak, {bool initial = false}) {
    if (streak >= _kMilestoneStreak) {
      // En la carga inicial, si ya tiene racha ≥ 7, celebra el hito.
      if (initial) {
        _startMilestone();
      } else {
        _state = _FrogState.resting;
      }
    } else if (awake) {
      if (initial) {
        _startHopping();
      } else {
        _state = _FrogState.resting;
      }
    } else {
      _state = _FrogState.sleeping;
    }
  }

  void _startHopping() {
    _cancelTimer();
    if (mounted) setState(() => _state = _FrogState.hopping);
    _timer = Timer(_kCelebrationDuration, () {
      if (mounted) setState(() => _state = _FrogState.resting);
    });
  }

  void _startMilestone() {
    _cancelTimer();
    if (mounted) setState(() => _state = _FrogState.milestone);
    _timer = Timer(_kMilestoneDuration, () {
      if (mounted) setState(() => _state = _FrogState.resting);
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ── Textos según estado ───────────────────────────────────────────────────

  static const _textDark = HabuuColors.success800;

  String get _message => switch (_state) {
        _FrogState.sleeping => 'Completa un hábito para despertar a Froggy',
        _FrogState.hopping => '¡Froggy ha despertado, sigue así!',
        _FrogState.resting => '¡Sigue así, vas muy bien!',
        _FrogState.milestone =>
          '¡${widget.streakCount} días de racha! ¡Increíble!',
      };

  // ── Construcción del widget Froggy ────────────────────────────────────────

  Widget _buildFrog() {
    return switch (_state) {
      _FrogState.sleeping => AnimatedFrog(
          key: const ValueKey(_FrogState.sleeping),
          asset: HomeAssets.frogSleeping,
          size: 160,
          motion: FrogMotion.breathe,
          semanticLabel: 'Froggy dormida',
        ),
      _FrogState.hopping => AnimatedFrog(
          key: const ValueKey(_FrogState.hopping),
          asset: HomeAssets.frogAwake,
          size: 160,
          motion: FrogMotion.hop,
          semanticLabel: 'Froggy despierta',
        ),
      _FrogState.resting => AnimatedFrog(
          key: const ValueKey(_FrogState.resting),
          asset: HomeAssets.frogResting,
          size: 160,
          motion: FrogMotion.breathe,
          semanticLabel: 'Froggy descansando',
        ),
      _FrogState.milestone => AnimatedFrog(
          key: const ValueKey(_FrogState.milestone),
          asset: HomeAssets.frogMilestone,
          size: 160,
          motion: FrogMotion.hop,
          semanticLabel: 'Froggy celebrando racha de ${widget.streakCount} días',
        ),
    };
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final showDecorativeImage =
        _state == _FrogState.hopping || _state == _FrogState.resting;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 32),
      decoration: const BoxDecoration(gradient: HabuuGradients.mintToSky),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Froggy centrada con transición suave entre estados.
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildFrog(),
            ),
          ),
          const SizedBox(height: 24),

          // Número de días + mensaje.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.streakCount}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 56,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.streakCount == 1 ? 'Día de racha' : 'Días de racha',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Imagen decorativa solo cuando está activa/descansando.
              if (showDecorativeImage)
                Image.asset(
                  'assets/images/calendar/streak_7.png',
                  height: 64,
                  fit: BoxFit.contain,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
