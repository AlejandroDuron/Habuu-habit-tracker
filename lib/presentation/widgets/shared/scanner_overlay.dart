import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';

/// Oscurece [child] y le pasa una franja de escáner por encima mientras
/// [active] es true. Al apagarse termina la pasada que lleva y quita la capa
/// con un fundido.
///
/// Si el teléfono tiene activado reducir movimiento, en lugar de la franja
/// muestra un indicador de carga.
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({
    super.key,
    required this.active,
    required this.child,
    this.borderRadius = BorderRadius.zero,
  });

  final bool active;
  final Widget child;

  /// Las mismas esquinas de [child], para que la franja no se salga.
  final BorderRadius borderRadius;

  static const label = 'Verificando foto…';

  /// Para encontrar la capa en las pruebas.
  static const overlayKey = ValueKey('scanner-overlay');

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  static const _passDuration = Duration(milliseconds: 1600);
  static const _fadeDuration = Duration(milliseconds: 200);

  late final AnimationController _controller;

  /// Si la capa está en el árbol (también mientras se desvanece).
  late bool _showOverlay;

  /// Si la capa se ve o se está desvaneciendo.
  late bool _visible;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _passDuration);
    _showOverlay = widget.active;
    _visible = widget.active;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.active) _sweep();
  }

  @override
  void didUpdateWidget(ScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _showOverlay = true;
      _visible = true;
      _sweep();
    } else if (!widget.active && oldWidget.active) {
      _finish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sweep() {
    if (_reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  Future<void> _finish() async {
    if (_controller.isAnimating) {
      // Que la franja termine de cruzar en vez de desaparecer a medio camino.
      try {
        await _controller.forward().orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (!mounted || widget.active) return;
    setState(() => _visible = false);
  }

  void _onFadeEnd() {
    if (_visible || !mounted) return;
    setState(() => _showOverlay = false);
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,
          if (_showOverlay)
            Positioned.fill(
              key: ScannerOverlay.overlayKey,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: _fadeDuration,
                onEnd: _onFadeEnd,
                child: Semantics(
                  label: ScannerOverlay.label,
                  liveRegion: true,
                  child: ExcludeSemantics(
                    child: _reduceMotion
                        ? const _StillOverlay()
                        : _SweepOverlay(animation: _controller),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Negro al 55 %.
const _dimColor = Color(0x8C000000);

class _SweepOverlay extends StatelessWidget {
  const _SweepOverlay({required this.animation});

  final Animation<double> animation;

  static const _bandColor = Color(0xFF5B5BE0);
  static const _glowColor = Color(0xFF2EC4E6);
  static const _edgeWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final band = width * 0.25;

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            // Empieza toda afuera a la izquierda y termina toda afuera a la
            // derecha, así al repetir no se nota el salto.
            final t = Curves.easeInOut.transform(animation.value);
            final left = -band + t * (width + band);

            return Stack(
              children: [
                const Positioned.fill(child: ColoredBox(color: _dimColor)),
                Positioned(
                  left: left,
                  top: 0,
                  bottom: 0,
                  width: band,
                  child: const Opacity(
                    opacity: 0.7,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x005B5BE0), _bandColor],
                        ),
                      ),
                    ),
                  ),
                ),
                // Borde de adelante, nítido y con brillo.
                Positioned(
                  left: left + band - _edgeWidth,
                  top: 0,
                  bottom: 0,
                  width: _edgeWidth,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: _glowColor,
                      boxShadow: [
                        BoxShadow(
                          color: _glowColor,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StillOverlay extends StatelessWidget {
  const _StillOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _dimColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: HabuuColors.white100,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ScannerOverlay.label,
              textAlign: TextAlign.center,
              style: HabuuText.captionSmMedium.copyWith(
                color: HabuuColors.white100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
