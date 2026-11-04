import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/models/user_profile.dart';
import '../../../utils/auth_feedback.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/profile/back_title_header.dart';
import '../../widgets/profile/pond_scroll_view.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/profile/profile_form.dart';

/// Datos personales del usuario: los muestra y deja editarlos.
class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  Future<void> _save(BuildContext context, UserProfile updated) async {
    final provider = context.read<ProfileProvider>();
    final ok = await provider.save(updated);
    if (!context.mounted) return;
    if (ok) {
      showAuthInfo(context, 'Cambios guardados');
    } else {
      showAuthError(context, provider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    return PondScrollView(
      children: [
        BackTitleHeader(
          title: 'Usuario',
          onBack: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 31),
        if (profile != null) ...[
          Center(child: ProfileAvatar(name: profile.fullName)),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProfileForm(
              // Si el perfil cambia de dueño, el formulario arranca de cero.
              key: ValueKey(profile.id),
              profile: profile,
              isSaving: provider.isSaving,
              onSave: (updated) => _save(context, updated),
            ),
          ),
        ] else if (provider.status == ProfileStatus.error)
          _LoadError(message: provider.errorMessage, onRetry: provider.load)
        else
          const Padding(
            padding: EdgeInsets.only(top: 120),
            child: Center(
              child: CircularProgressIndicator(color: HabuuColors.primary500),
            ),
          ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Text(
            message ?? 'No se pudo cargar tu perfil',
            textAlign: TextAlign.center,
            style: HabuuText.bodyLgRegular.copyWith(
              color: HabuuTextColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 24),
          AuthButton(label: 'Reintentar', onPressed: onRetry),
        ],
      ),
    );
  }
}
