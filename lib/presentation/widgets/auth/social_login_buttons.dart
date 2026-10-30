import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habuu/config/assets.dart';
import 'package:habuu/config/theme/tokens.dart';

/// Fila con los botones de Apple, Microsoft y Google.
/// Por ahora no hacen nada: conecta los callbacks cuando exista el backend.
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({
    super.key,
    this.onApple,
    this.onMicrosoft,
    this.onGoogle,
  });

  final VoidCallback? onApple;
  final VoidCallback? onMicrosoft;
  final VoidCallback? onGoogle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          asset: AuthAssets.apple,
          label: 'Continuar con Apple',
          onTap: onApple,
        ),
        const SizedBox(width: 16),
        _SocialButton(
          asset: AuthAssets.microsoft,
          label: 'Continuar con Microsoft',
          onTap: onMicrosoft,
        ),
        const SizedBox(width: 16),
        _SocialButton(
          asset: AuthAssets.google,
          label: 'Continuar con Google',
          onTap: onGoogle,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: HabuuColors.primary500, width: 1.5),
        ),
        child: InkWell(
          // TODO: conectar con el backend (OAuth).
          onTap: onTap ?? () {},
          child: SizedBox(
            width: 56,
            height: 52,
            child: Center(
              child: SvgPicture.asset(
                asset,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
