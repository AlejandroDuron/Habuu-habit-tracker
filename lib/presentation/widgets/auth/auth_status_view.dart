import 'package:flutter/material.dart';
import 'package:habuu/config/theme/tokens.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:habuu/presentation/widgets/auth/auth_scaffold.dart';

/// Pantalla centrada con rana + mensaje + botón opcional.
/// Base de "Nuevo código enviado" y "Cuenta verificada con éxito".
class AuthStatusView extends StatelessWidget {
  const AuthStatusView({
    super.key,
    required this.frogAsset,
    required this.title,
    this.buttonLabel,
    this.onPressed,
    this.frogWidth = 130,
  });

  final String frogAsset;
  final String title;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final double frogWidth;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      centered: true,
      children: [
        Center(child: Image.asset(frogAsset, width: frogWidth)),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: HabuuText.h5ExtraBold,
        ),
        if (buttonLabel != null) ...[
          const SizedBox(height: 28),
          AuthButton(label: buttonLabel!, onPressed: onPressed),
        ],
      ],
    );
  }
}
