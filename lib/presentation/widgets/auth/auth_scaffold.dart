import 'package:flutter/material.dart';
import 'package:habuu/config/theme/tokens.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.showBack = false,
    this.centered = false,
  });

  final List<Widget> children;

  /// Muestra la flecha de volver arriba a la izquierda.
  final bool showBack;

  /// Centra el contenido verticalmente (pantallas de estado).
  final bool centered;

  static const _bottomPadding = 24.0;
  static const _maxContentWidth = 440.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HabuuGradients.skyToMint),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(30, 0, 30, _bottomPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _maxContentWidth,
                      minHeight: constraints.maxHeight - _bottomPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: centered
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showBack) const _AuthBackButton(),
                        ...children,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: HabuuIconColors.black,
          size: 22,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: 'Volver',
      ),
    );
  }
}