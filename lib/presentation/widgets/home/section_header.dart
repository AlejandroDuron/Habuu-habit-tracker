import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

/// Título de sección con el enlace "Mostrar" a la derecha.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onShowMore});

  final String title;

  /// Acción de "Mostrar". Aún no navega a ningún lado.
  final VoidCallback? onShowMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: HabuuText.subtitleSmMedium)),
        GestureDetector(
          onTap: onShowMore,
          child: Text(
            'Mostrar',
            style: HabuuText.captionMdMedium.copyWith(
              color: HabuuColors.primary600,
            ),
          ),
        ),
      ],
    );
  }
}
