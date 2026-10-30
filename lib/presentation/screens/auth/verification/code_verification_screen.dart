import 'package:flutter/material.dart';
import 'package:habuu/config/assets.dart';
import 'package:habuu/config/theme/tokens.dart';
import 'package:habuu/presentation/screens/auth/verification/code_sent_screen.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:habuu/presentation/widgets/auth/auth_scaffold.dart';
import 'package:habuu/presentation/widgets/auth/code_input.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';
import 'package:habuu/utils/auth_feedback.dart';
import 'package:provider/provider.dart';

/// Pantalla reutilizable para ingresar el código de 5 dígitos.
/// La usan el registro ("Verificar cuenta") y la recuperación de contraseña
/// ("Verificar código"). El [AuthProvider] sabe qué flujo está activo; esta
/// pantalla solo decide qué hacer después en [onVerified].
class CodeVerificationScreen extends StatefulWidget {
  const CodeVerificationScreen({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onVerified,
  });

  final String title;
  final String buttonLabel;
  final void Function(BuildContext context) onVerified;

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  static const _codeLength = 5;

  String _code = '';
  String? _errorText;

  Future<void> _verify() async {
    if (_code.length != _codeLength) {
      setState(() => _errorText = 'Ingresa los $_codeLength dígitos del código');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyCode(_code);
    if (!mounted) return;

    if (!ok) {
      setState(() => _errorText = auth.errorMessage ?? 'Código incorrecto');
      return;
    }
    widget.onVerified(context);
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.resendCode();
    if (!mounted) return;

    if (!ok) {
      showAuthError(context, auth.errorMessage);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CodeSentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((a) => a.isLoading);

    return AuthScaffold(
      showBack: true,
      children: [
        Center(child: Image.asset(AuthAssets.frogPolice, height: 130)),
        const SizedBox(height: 16),
        Text(widget.title, style: HabuuText.h5ExtraBold),
        const SizedBox(height: 32),
        CodeInput(
          length: _codeLength,
          hasError: _errorText != null,
          onChanged: (code) => setState(() {
            _code = code;
            _errorText = null;
          }),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: HabuuText.captionMdMedium.copyWith(
              color: HabuuColors.error600,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: isLoading ? null : _resend,
            child: Text(
              'Enviar código de nuevo',
              style: HabuuText.subtitleSmMedium.copyWith(
                fontWeight: HabuuWeight.bold,
                color: HabuuTextColors.links,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AuthButton(
          label: widget.buttonLabel,
          onPressed: _verify,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
