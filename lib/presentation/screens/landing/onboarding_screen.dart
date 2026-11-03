import 'package:flutter/material.dart';

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

class _C {
  static const darkGreen = Color(0xFF11553A);
  static const titleGreen = Color(0xFF2F7A5A);
  static const subtitle = Color(0xFF5E6B66);
  static const bgTop = Color(0xFFE4F6F9);
  static const bgBottom = Color(0xFFCDEEDC);
  static const dotInactive = Color(0xFFA9D3C0);
}

class OnboardingScreen extends StatefulWidget {
  /// Se ejecuta al pulsar "Omitir" o "¡Empezemos!".
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  late final List<_PageData> _pages = [
    _PageData(
      title: 'Construye hábitos que\ntransformen tu día',
      subtitle: 'Pequeñas acciones, grandes cambios',
      content: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: .86,
          child: Image.asset(_Assets.habitsCard, width: 320),
        ),
      ),
      overlay: Image.asset(_Assets.froggyClipboard, width: 145),
      overlayLeft: 24,
      overlayWidth: 145,
      overlayBottomOffset: 50,
    ),
    _PageData(
      title: 'Mantén tus rachas\npara ganar trofeos',
      subtitle: '¡Y haz que Froggy salte de alegría!',
      content: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(_Assets.streakCard, width: 230),
            const SizedBox(height: 12),
            Image.asset(_Assets.trophies, width: 320),
          ],
        ),
      ),
      overlay: Image.asset(_Assets.duck, width: 62),
      overlayRight: 80,
      overlayWidth: 62,
      overlayBottomOffset: 40,
    ),
    _PageData(
      title: 'Establece\nrecordatorios',
      subtitle: '¡Sino Froggy se ponga triste!',
      content: Image.asset(_Assets.remindersCard, width: 320),
      overlay: Image.asset(_Assets.froggySurprised, width: 128),
      overlayRight: 24,
      overlayWidth: 128,
      overlayBottomOffset: 50,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sheetHeight = (constraints.maxHeight * .52)
              .clamp(280.0, 340.0)
              .toDouble();

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_C.bgTop, _C.bgBottom],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  bottom: sheetHeight,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemBuilder: (_, i) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                        child: LayoutBuilder(
                          builder: (context, contentConstraints) => SizedBox(
                            width: contentConstraints.maxWidth,
                            height: contentConstraints.maxHeight,
                            child: FittedBox(
                              alignment: Alignment.topCenter,
                              fit: BoxFit.scaleDown,
                              child: _pages[i].content,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: sheetHeight,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          _Dots(current: _current, total: _pages.length),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: _next,
                              style: FilledButton.styleFrom(
                                backgroundColor: _C.darkGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _isLast ? '¡Empezemos!' : 'Siguiente',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Omitir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: page.overlayLeft,
                  right: page.overlayRight,
                  bottom: sheetHeight - page.overlayBottomOffset,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: SizedBox(
                      key: ValueKey(_current),
                      width: page.overlayWidth,
                      child: page.overlay,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PageData {
  final String title, subtitle;
  final Widget content;
  final Widget overlay;
  final double? overlayLeft;
  final double? overlayRight;
  final double overlayWidth;
  final double overlayBottomOffset;
  const _PageData({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.overlay,
    this.overlayLeft,
    this.overlayRight,
    required this.overlayWidth,
    required this.overlayBottomOffset,
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
