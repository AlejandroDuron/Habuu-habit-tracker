import 'package:flutter/material.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';

/// Aviso de "Tu ranita" con el acceso directo al estanque.
class PondAlertCard extends StatelessWidget {
  const PondAlertCard({
    super.key,
    required this.onGoToPond,
    this.title = 'Tu ranita',
    this.message = '¡El ecosistema necesita tu ayuda, sigue así!',
  });

  final VoidCallback onGoToPond;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: BorderRadius.circular(HabuuRadius.sm),
        border: Border.all(color: const Color(0x3D000000)),
      ),
      child: Row(
        children: [
          Image.asset(ProfileAssets.frogHeadphones, width: 24, height: 24),
          const SizedBox(width: 16),
          Expanded(
            child: _Bubble(title: title, message: message, onTap: onGoToPond),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.title,
    required this.message,
    required this.onTap,
  });

  final String title;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: HabuuColors.success50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: HabuuColors.black20,
            offset: Offset(0, 4),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: HabuuText.subtitleSmMedium.copyWith(
              fontWeight: HabuuWeight.semibold,
              color: HabuuColors.success600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: HabuuText.bodySmMedium.copyWith(
              color: HabuuColors.success700,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(HabuuRadius.sm),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                'Ir al Estanque',
                style: HabuuText.subtitleSmMedium.copyWith(
                  fontWeight: HabuuWeight.bold,
                  color: HabuuColors.success700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
