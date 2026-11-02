import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Movimientos disponibles para la ranita.
enum FrogMotion {
  /// Saltitos en el mismo lugar, se aplasta al caer.
  hop,

  /// Se balancea de lado a lado, inclinándose un poco.
  sway,

  /// Salta de un lado al otro.
  hopSideToSide,

  /// Respira despacio, como cuando está dormida.
  breathe,
}

/// Ranita animada que se repite en bucle.
///
/// Si el sistema tiene las animaciones reducidas, la ranita se queda quieta.
class AnimatedFrog extends StatefulWidget {
  const AnimatedFrog({
    super.key,
    required this.asset,
    this.size = 120,
    this.motion = FrogMotion.hop,
    this.duration,
    this.hopHeight = 0.35,
    this.sideDistance = 0.3,
    this.showShadow = true,
    this.semanticLabel,
  }) : assert(size > 0, 'El tamaño tiene que ser mayor que 0'),
       assert(hopHeight >= 0, 'La altura del salto no puede ser negativa'),
       assert(sideDistance >= 0, 'La distancia lateral no puede ser negativa');

  /// Ruta del PNG, idealmente con fondo transparente.
  final String asset;

  /// Tamaño de la ranita en píxeles lógicos.
  final double size;

  final FrogMotion motion;

  /// Duración de un ciclo completo. Si es null se usa una según [motion].
  final Duration? duration;

  /// Altura del salto como fracción de [size].
  final double hopHeight;

  /// Desplazamiento lateral como fracción de [size].
  final double sideDistance;

  /// Sombrita en el piso que se encoge cuando la rana sube.
  final bool showShadow;

  /// Texto para el lector de pantalla.
  final String? semanticLabel;

  @override
  State<AnimatedFrog> createState() => _AnimatedFrogState();
}

class _AnimatedFrogState extends State<AnimatedFrog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  Duration get _duration =>
      widget.duration ??
      switch (widget.motion) {
        FrogMotion.hop => const Duration(milliseconds: 900),
        FrogMotion.sway => const Duration(milliseconds: 1600),
        FrogMotion.hopSideToSide => const Duration(milliseconds: 1800),
        FrogMotion.breathe => const Duration(milliseconds: 3200),
      };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _syncController();
  }

  @override
  void didUpdateWidget(covariant AnimatedFrog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion != widget.motion ||
        oldWidget.duration != widget.duration) {
      _controller.duration = _duration;
      _syncController(restart: true);
    }
  }

  /// Arranca o detiene el bucle según la preferencia de animaciones.
  void _syncController({bool restart = false}) {
    if (_reduceMotion) {
      // En t = 0 todos los movimientos están en su pose de descanso.
      _controller
        ..stop()
        ..value = 0;
    } else if (restart || !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final frog = Image.asset(
      widget.asset,
      width: s,
      height: s,
      fit: BoxFit.contain,
      semanticLabel: widget.semanticLabel,
    );

    return RepaintBoundary(
      child: SizedBox(
        width: s * (1 + 2 * widget.sideDistance),
        height: s * (1 + widget.hopHeight) + s * 0.1,
        child: AnimatedBuilder(
          animation: _controller,
          child: frog,
          builder: (context, child) {
            final t = _controller.value;
            final pose = switch (widget.motion) {
              FrogMotion.hop => _hop(t),
              FrogMotion.sway => _sway(t),
              FrogMotion.hopSideToSide => _hopSideToSide(t),
              FrogMotion.breathe => _breathe(t),
            };

            return Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                if (widget.showShadow)
                  Positioned(
                    bottom: 0,
                    child: Transform.translate(
                      offset: Offset(pose.dx * s, 0),
                      child: _Shadow(
                        width: s * 0.6 * (1 - pose.lift * 0.5),
                        height: s * 0.08,
                        opacity: 0.18 * (1 - pose.lift * 0.6),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: s * 0.04,
                  child: Transform.translate(
                    offset: Offset(
                      pose.dx * s,
                      -pose.lift * widget.hopHeight * s,
                    ),
                    child: Transform.rotate(
                      angle: pose.angle,
                      alignment: Alignment.bottomCenter,
                      child: Transform.scale(
                        scaleX: pose.scaleX,
                        scaleY: pose.scaleY,
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Un salto: se agacha, vuela, aterriza aplastándose y descansa.
  _Pose _hop(double t, {double dxFrom = 0, double dxTo = 0}) {
    const crouchEnd = 0.15, airEnd = 0.65, landEnd = 0.80;

    if (t < crouchEnd) {
      // Se agacha para tomar impulso.
      final p = t / crouchEnd;
      final sq = 0.12 * math.sin(math.pi * p);
      return _Pose(dx: dxFrom, scaleX: 1 + sq, scaleY: 1 - sq);
    }

    if (t < airEnd) {
      // En el aire: sube, baja y se estira un poco.
      final p = (t - crouchEnd) / (airEnd - crouchEnd);
      final lift = math.sin(math.pi * p);
      final stretch = 0.08 * math.sin(2 * math.pi * p).abs();
      final dx = dxFrom + (dxTo - dxFrom) * Curves.easeInOut.transform(p);
      final tilt = (dxTo - dxFrom).sign * 0.12 * math.sin(math.pi * p);
      return _Pose(
        dx: dx,
        lift: lift,
        angle: tilt,
        scaleX: 1 - stretch / 2,
        scaleY: 1 + stretch,
      );
    }

    if (t < landEnd) {
      // Aterriza y se aplasta.
      final p = (t - airEnd) / (landEnd - airEnd);
      final sq = 0.15 * math.sin(math.pi * p);
      return _Pose(dx: dxTo, scaleX: 1 + sq * 0.8, scaleY: 1 - sq);
    }

    return _Pose(dx: dxTo);
  }

  /// Vaivén lateral con inclinación y un rebotito al caminar.
  _Pose _sway(double t) {
    final w = 2 * math.pi * t;
    return _Pose(
      dx: math.sin(w) * widget.sideDistance,
      angle: math.cos(w) * 0.12,
      lift: math.sin(2 * w).abs() * 0.12,
    );
  }

  /// Dos saltos por ciclo: izquierda, derecha y de regreso.
  _Pose _hopSideToSide(double t) {
    final d = widget.sideDistance;
    return t < 0.5
        ? _hop(t * 2, dxFrom: -d, dxTo: d)
        : _hop((t - 0.5) * 2, dxFrom: d, dxTo: -d);
  }

  /// Se infla un poquito al inhalar y se desinfla al exhalar.
  _Pose _breathe(double t) {
    final b = math.sin(2 * math.pi * t);
    return _Pose(scaleX: 1 - 0.015 * b, scaleY: 1 + 0.03 * b);
  }
}

class _Pose {
  const _Pose({
    this.dx = 0,
    this.lift = 0,
    this.angle = 0,
    this.scaleX = 1,
    this.scaleY = 1,
  });

  /// Desplazamiento horizontal, como fracción de size.
  final double dx;

  /// Altura del salto: 0 es el piso y 1 la altura máxima.
  final double lift;

  /// Rotación en radianes.
  final double angle;

  final double scaleX;
  final double scaleY;
}

class _Shadow extends StatelessWidget {
  const _Shadow({
    required this.width,
    required this.height,
    required this.opacity,
  });

  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Color.fromRGBO(0, 0, 0, opacity),
        shape: const OvalBorder(),
      ),
    );
  }
}
