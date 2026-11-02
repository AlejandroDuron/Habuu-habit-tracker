import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';

/// Fondo del estanque con el contenido en columna y scroll.
/// Base de las pantallas del perfil que viven dentro de la barra inferior.
class PondScrollView extends StatelessWidget {
  const PondScrollView({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: HabuuGradients.pond),
        child: SafeArea(
          bottom: false,
          child: SizedBox.expand(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(35, 24, 35, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
