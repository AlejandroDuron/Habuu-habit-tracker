import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/models/trophy.dart';

/// Mapeo de trophy_key → ruta del asset de imagen (igual que en TrophiesScreen).
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

/// Toast animado que aparece cuando el usuario gana un trofeo nuevo.
///
/// Se muestra desde abajo, permanece 3 segundos y desaparece hacia arriba.
/// Para usarlo, envuelve la pantalla con un [Stack] y agrega este widget
/// condicionalmente cuando [TrophiesProvider.newlyEarned] no está vacío.
class TrophyEarnedToast extends StatefulWidget {
  const TrophyEarnedToast({
    super.key,
    required this.trophy,
    required this.onDismissed,
  });

  final EarnedTrophy trophy;

  /// Se llama cuando la animación de salida termina (o tras el timeout).
  final VoidCallback onDismissed;

  @override
  State<TrophyEarnedToast> createState() => _TrophyEarnedToastState();
}

class _TrophyEarnedToastState extends State<TrophyEarnedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  static const _showDuration = Duration(seconds: 3);
  static const _animDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _animDuration);

    _slide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Entra
    _controller.forward();

    // Después de [_showDuration] sale y notifica
    Future.delayed(_showDuration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trophy = widget.trophy.trophy;

    return Positioned(
      left: 24,
      right: 24,
      bottom: 100, // Por encima de la navbar
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: HabuuColors.success800,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: HabuuColors.black30,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Imagen del trofeo
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: HabuuColors.success0,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        _imageForKey(trophy.key),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Textos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¡Trofeo ganado!',
                            style: HabuuText.captionMdMedium.copyWith(
                              color: HabuuColors.success200,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trophy.name,
                            style: HabuuText.bodySmSemibold.copyWith(
                              color: HabuuColors.white100,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Botón de cierre
                    IconButton(
                      onPressed: _dismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: HabuuColors.white60,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
