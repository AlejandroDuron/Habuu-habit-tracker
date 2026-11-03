import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/home/frog_mood.dart';

/// Calcula cómo está Froggy y se vuelve a dibujar cuando termina la
/// celebración, para que pase sola de saltar a descansar.
class FrogMoodBuilder extends StatefulWidget {
  const FrogMoodBuilder({
    super.key,
    required this.awake,
    required this.lastDoneAt,
    required this.builder,
  });

  final bool awake;
  final DateTime? lastDoneAt;
  final Widget Function(BuildContext context, FrogMood mood) builder;

  @override
  State<FrogMoodBuilder> createState() => _FrogMoodBuilderState();
}

class _FrogMoodBuilderState extends State<FrogMoodBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleEnd();
  }

  @override
  void didUpdateWidget(covariant FrogMoodBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Otro hábito cumplido: la celebración empieza de nuevo.
    if (oldWidget.lastDoneAt != widget.lastDoneAt) _scheduleEnd();
  }

  /// Programa el redibujo para cuando se acaben los segundos de salto.
  void _scheduleEnd() {
    _timer?.cancel();
    final lastDoneAt = widget.lastDoneAt;
    if (lastDoneAt == null) return;

    final left = celebrationDuration - DateTime.now().difference(lastDoneAt);
    if (left <= Duration.zero) return;

    _timer = Timer(left, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = frogMoodFor(
      awake: widget.awake,
      lastDoneAt: widget.lastDoneAt,
      now: DateTime.now(),
    );
    return widget.builder(context, mood);
  }
}
