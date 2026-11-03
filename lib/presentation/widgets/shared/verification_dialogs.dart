import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';

/// Pregunta si se pueden mandar las fotos a Google para revisarlas.
/// Devuelve true si el usuario acepta.
Future<bool> showVerificationConsentDialog(BuildContext context) async {
  final accepted = await showDialog<bool>(
    context: context,
    // Tiene que elegir una opción; cerrar el diálogo no cuenta como respuesta.
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('¿Verificar tus fotos?'),
      content: const Text(
        'Para revisar que la foto tenga que ver con el hábito, la enviamos a '
        'Gemini, un servicio de Google que la analiza.\n\n'
        'Evita fotos con personas o datos personales. Puedes cambiar esto '
        'cuando quieras en Perfil > Seguridad.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No verificar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: HabuuColors.primary500,
          ),
          child: const Text('Verificar'),
        ),
      ],
    ),
  );
  return accepted ?? false;
}

/// Avisa qué pasa si se quita la verificación. Devuelve true si confirma.
Future<bool> showDisableVerificationDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Quitar la verificación?'),
      content: const Text(
        'Tus fotos ya no se enviarán a Google, pero tampoco se revisarán: '
        'cualquier foto servirá para marcar un hábito como cumplido.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: HabuuColors.error600),
          child: const Text('Quitar'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
