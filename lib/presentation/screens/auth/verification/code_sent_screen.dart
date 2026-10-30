import 'package:flutter/material.dart';
import 'package:habuu/config/assets.dart';
import 'package:habuu/presentation/widgets/auth/auth_status_view.dart';

/// "Nuevo código enviado". Aceptar vuelve a la pantalla del código.
class CodeSentScreen extends StatelessWidget {
  const CodeSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStatusView(
      frogAsset: AuthAssets.frogHappy,
      title: 'Nuevo código\nenviado',
      buttonLabel: 'Aceptar',
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
