import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

/// Saludo en la parte superior del Home.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.title = 'Bienvenido de nuevo',
    this.subtitle = 'Hora de regresar al estanque',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: HabuuText.h5ExtraBold.copyWith(color: HabuuColors.success800),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: HabuuText.subtitleMdBold.copyWith(
            color: HabuuColors.success800,
          ),
        ),
      ],
    );
  }
}
