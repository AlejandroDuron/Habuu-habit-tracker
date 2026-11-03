import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../providers/verification_settings_provider.dart';
import '../../widgets/habits/habit_switch_row.dart';
import '../../widgets/profile/back_title_header.dart';
import '../../widgets/profile/pond_scroll_view.dart';
import '../../widgets/shared/verification_dialogs.dart';

/// Opciones de seguridad. Por ahora, si las fotos se revisan con Gemini.
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  Future<void> _onChanged(BuildContext context, bool enable) async {
    final settings = context.read<VerificationSettingsProvider>();

    // En los dos casos se explica qué implica antes de cambiarlo.
    final confirmed = enable
        ? await showVerificationConsentDialog(context)
        : await showDisableVerificationDialog(context);
    if (!context.mounted || !confirmed) return;

    await settings.setEnabled(enable);
  }

  @override
  Widget build(BuildContext context) {
    // Si nunca se le preguntó, se muestra encendida: se le va a preguntar
    // con la primera foto.
    final enabled = context.watch<VerificationSettingsProvider>().enabled;

    return PondScrollView(
      children: [
        BackTitleHeader(
          title: 'Seguridad',
          onBack: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 31),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HabuuColors.white100,
            borderRadius: BorderRadius.circular(HabuuRadius.sm),
            boxShadow: habuuElevation500,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HabitSwitchRow(
                label: 'Verificar fotos de evidencia',
                value: enabled != false,
                onChanged: (value) => _onChanged(context, value),
              ),
              const SizedBox(height: 8),
              Text(
                'Antes de marcar un hábito, la foto se envía a Gemini '
                '(Google) para revisar que tenga que ver con el hábito. '
                'Si la quitas, cualquier foto sirve.',
                style: HabuuText.bodySmMedium.copyWith(
                  color: HabuuColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
