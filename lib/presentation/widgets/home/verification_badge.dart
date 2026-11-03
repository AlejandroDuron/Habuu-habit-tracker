import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../models/home/evidence_check.dart';

/// Etiqueta con el resultado de la revisión de la foto.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.status})
    : assert(
        status != VerificationStatus.verificando,
        'Mientras verifica se muestra el escáner, no la etiqueta',
      );

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, background, foreground) = switch (status) {
      VerificationStatus.verificado => (
        'Verificado',
        Icons.verified_rounded,
        HabuuColors.primary0,
        HabuuColors.primary500,
      ),
      VerificationStatus.noConfirmado => (
        'No confirmado',
        Icons.help_outline_rounded,
        HabuuColors.warning50,
        HabuuColors.warning800,
      ),
      _ => (
        'No se pudo verificar',
        Icons.cloud_off_rounded,
        HabuuColors.grey50,
        HabuuColors.grey800,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: HabuuText.captionMdMedium.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
