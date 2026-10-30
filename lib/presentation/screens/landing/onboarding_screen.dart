import 'package:flutter/material.dart';

// ───────────────────────── Assets ─────────────────────────
class _Assets {
  static const base = 'assets/images/onboarding';
  static const habitsCard = '$base/habits_card.png';
  static const streakCard = '$base/streak_card.png';
  static const remindersCard = '$base/reminders_card.png';
  static const trophies = '$base/trophies.png';
  static const froggyClipboard = '$base/froggy_clipboard.png';
  static const froggySurprised = '$base/froggy_surprised.png';
  static const duck = '$base/duck.png';
}

// ───────────────────────── Colores ─────────────────────────
class _C {
  static const darkGreen = Color(0xFF11553A);
  static const titleGreen = Color(0xFF2F7A5A);
  static const subtitle = Color(0xFF5E6B66);
  static const bgTop = Color(0xFFE4F6F9);
  static const bgBottom = Color(0xFFCDEEDC);
  static const dotInactive = Color(0xFFA9D3C0);
}

// ───────────────────────── Pantalla ─────────────────────────
class OnboardingScreen extends StatefulWidget {
  /// Se ejecuta al pulsar "Omitir" o "¡Empezemos!".
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const double _sheetHeight = 340;

  final _controller = PageController();
  int _current = 0;

  late final List<_PageData> _pages = [
    _PageData(
      title: 'Construye hábitos que\ntransformen tu día',
      subtitle: 'Pequeñas acciones, grandes cambios',
      content: LayoutBuilder(
        builder: (_, c) => ClipRect(
          // la imagen trae espacio transparente abajo
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: .86,
            child: Image.asset(_Assets.habitsCard, width: c.maxWidth * .85),
          ),
        ),
      ),
      overlay: Positioned(
        left: 24,
        bottom: _sheetHeight - 50,
        child: Image.asset(_Assets.froggyClipboard, width: 145),
      ),
    ),
    _PageData(
      title: 'Mantén tus rachas\npara ganar trofeos',
      subtitle: '¡Y haz que Froggy salte de alegría!',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(_Assets.streakCard, width: 230),
          const SizedBox(height: 12),
          Image.asset(_Assets.trophies, width: 320),
        ],
      ),
      overlay: Positioned(
        right: 80,
        bottom: _sheetHeight - 40,
        child: Image.asset(_Assets.duck, width: 62),
      ),
    ),
    _PageData(
      title: 'Establece\nrecordatorios',
      subtitle: '¡Sino Froggy se ponga triste!',
      content: LayoutBuilder(
        builder: (_, c) =>
            Image.asset(_Assets.remindersCard, width: c.maxWidth * .85),
      ),
      overlay: Positioned(
        right: 24,
        bottom: _sheetHeight - 50,
        child: Image.asset(_Assets.froggySurprised, width: 128),
      ),
    ),
  ];

  bool get _isLast => _current == _pages.length - 1;

  void _next() {
    if (_isLast) {
      widget.onFinish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_current];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.bgTop, _C.bgBottom],
          ),
        ),
        child: Stack(
          children: [
            // Contenido deslizable (ilustración + overlay)
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    bottom: _sheetHeight,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _pages[i].content,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Panel blanco fijo
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _sheetHeight,
              child: Container(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Column(
                          key: ValueKey(_current),
                          children: [
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                                color: _C.titleGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _C.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _Dots(current: _current, total: _pages.length),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: _C.darkGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            _isLast ? '¡Empezemos!' : 'Siguiente',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Mantiene el espacio para que el botón no salte de lugar
                      Visibility(
                        visible: !_isLast,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: widget.onFinish,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _C.darkGreen,
                              side: const BorderSide(color: _C.darkGreen),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Omitir',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),

            // Mascota / patito que sobresale del panel (cambia con la página)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Stack(
                key: ValueKey(_current),
                clipBehavior: Clip.none,
                children: [page.overlay],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final String title, subtitle;
  final Widget content;
  final Positioned overlay;
  const _PageData({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.overlay,
  });
}

class _Dots extends StatelessWidget {
  final int current, total;
  const _Dots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == current ? _C.darkGreen : _C.dotInactive,
          ),
        );
      }),
    );
  }
}
