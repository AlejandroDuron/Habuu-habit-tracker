import 'package:flutter/material.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';
import 'package:habuu/utils/auth_feedback.dart';
import 'package:provider/provider.dart';
import 'package:habuu/config/assets.dart';
import 'package:habuu/config/theme/tokens.dart';
import 'package:habuu/presentation/screens/auth/password/change_password.dart';
import 'package:habuu/presentation/screens/auth/verification/code_verification_screen.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:habuu/presentation/widgets/auth/auth_scaffold.dart';
import 'package:habuu/presentation/widgets/auth/auth_text_field.dart';
import 'package:habuu/utils/validators.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _recover() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.requestPasswordReset(_emailController.text);
    if (!mounted) return;
    if (!ok) {
      showAuthError(context, auth.errorMessage);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CodeVerificationScreen(
          title: 'Verificación de\ncódigo',
          buttonLabel: 'Verificar código',
          onVerified: (ctx) => Navigator.of(ctx).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recuperar\ncontraseña',
                style: HabuuText.h5ExtraBold,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(AuthAssets.frogConfused, width: 92),
          ],
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: AuthTextField(
            label: 'Correo electrónico de recuperación',
            controller: _emailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _recover(),
          ),
        ),
        const SizedBox(height: 28),
        AuthButton(
          label: 'Recuperar contraseña',
          onPressed: _recover,
          isLoading: context.select<AuthProvider, bool>((a) => a.isLoading),
        ),
      ],
    );
  }
}
