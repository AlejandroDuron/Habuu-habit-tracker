import 'package:flutter/material.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../widgets/profile/profile_action_button.dart';

/// "¿Estás seguro?" antes de cerrar sesión.
/// Solo muestra la pregunta; quien la abre decide qué pasa con cada respuesta.
class LogoutConfirmScreen extends StatelessWidget {
  const LogoutConfirmScreen({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: HabuuGradients.blush),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    ProfileAssets.frogCrying,
                    width: 126,
                    height: 103,
                    semanticLabel: 'Ranita llorando',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¿Estás seguro?',
                    textAlign: TextAlign.center,
                    style: HabuuText.h3Bold.copyWith(
                      color: HabuuColors.error700,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ProfileActionButton.filled(
                    label: 'Cerrar sesión',
                    onPressed: onConfirm,
                  ),
                  const SizedBox(height: 30),
                  ProfileActionButton.outlined(
                    label: 'Volver a Habuu',
                    onPressed: onCancel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
