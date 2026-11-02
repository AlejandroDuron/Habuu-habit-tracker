import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../shared/animated_frog.dart';

/// Cuánto dura la animación de "despertar" antes de pasar a descanso.
const _kWakeDuration = Duration(seconds: 10);

/// Tres estados posibles para Froggy en la pantalla de rachas.
enum _FrogState {
  /// Sin racha y sin hábitos completados hoy → duerme.
  sleeping,

  /// Acaba de completar un hábito / tiene racha → salta (máx. 10 s).
  hopping,

  /// Pasaron los 10 s de salto → descansa animada con habuu_resting.
  resting,
}

/// Header de la pantalla de Rachas.
///
/// - Sin racha y sin hábito completado hoy → Froggy duerme.
/// - Completó un hábito hoy o tiene racha → Froggy salta 10 s y luego descansa.
class StreakHeader extends StatefulWidget {
  const StreakHeader({
    super.key,
    required this.streakCount,
    this.frogAwake = false,
  });

  final int streakCount;

  /// true si el usuario completó al menos un hábito hoy.
  final bool frogAwake;

  @override
  State<StreakHeader> createState() => _StreakHeaderState();
}

class _StreakHeaderState extends State<StreakHeader> {
  _FrogState _frogState = _FrogState.sleeping;
  Timer? _wakeTimer;

  @override
  void initState() {
    super.initState();
    _applyFrogAwake(widget.frogAwake);
  }

  @override
  void didUpdateWidget(covariant StreakHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo reacciona cuando frogAwake cambia de false → true.
    if (!oldWidget.frogAwake && widget.frogAwake) {
      _startHopping();
    } else if (!widget.frogAwake && _frogState != _FrogState.sleeping) {
      // Si pierde la racha y no tiene hábitos → vuelve a dormir.
      _cancelTimer();
      setState(() => _frogState = _FrogState.sleeping);
    }
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _applyFrogAwake(bool awake) {
    if (awake) {
      _startHopping();
    } else {
      _frogState = _FrogState.sleeping;
    }
  }

  void _startHopping() {
    _cancelTimer();
    setState(() => _frogState = _FrogState.hopping);
    _wakeTimer = Timer(_kWakeDuration, () {
      if (mounted) setState(() => _frogState = _FrogState.resting);
    });
  }

  void _cancelTimer() {
    _wakeTimer?.cancel();
    _wakeTimer = null;
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  static const Color _textDark = HabuuColors.success800;

  String get _message => switch (_frogState) {
        _FrogState.sleeping =>
          'Completa un hábito para despertar a Froggy',
        _FrogState.hopping => '¡Froggy ha despertado, sigue así!',
        _FrogState.resting => '¡Sigue así, vas muy bien!',
      };

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isAwakeOrResting = _frogState != _FrogState.sleeping;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 32),
      decoration: const BoxDecoration(gradient: HabuuGradients.mintToSky),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Froggy centrada.
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
                      widget.streakCount == 1
                          ? 'Día de racha'
                          : 'Días de racha',
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
              // Patito decorativo solo cuando está activa/descansando.
              if (isAwakeOrResting)
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

  Widget _buildFrog() {
    return switch (_frogState) {
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
    };
  }
}
