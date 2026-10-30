import 'package:flutter/material.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';
import 'package:habuu/utils/auth_feedback.dart';
import 'package:provider/provider.dart';
import 'package:habuu/config/assets.dart';
import 'package:habuu/config/routes.dart';
import 'package:habuu/config/theme/tokens.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:habuu/presentation/widgets/auth/auth_scaffold.dart';
import 'package:habuu/presentation/widgets/auth/auth_text_field.dart';
import 'package:habuu/presentation/widgets/auth/social_login_buttons.dart';
import 'package:habuu/presentation/widgets/shared/habuu_shell.dart';
import 'package:habuu/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!ok) {
      showAuthError(context, auth.errorMessage);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HabuuShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 32),
        Center(child: Image.asset(AuthAssets.frogMain, width: 200)),
        const SizedBox(height: 8),
        Text(
          'Iniciar sesión',
          textAlign: TextAlign.center,
          style: HabuuText.h5ExtraBold,
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: 'Correo electrónico',
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Contraseña',
                controller: _passwordController,
                hint: AuthTextField.passwordHint,
                obscureText: true,
                helperText: Validators.passwordRules,
                validator: (v) =>
                    Validators.notEmpty(v, 'Ingresa tu contraseña'),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _login(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.recover),
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: HabuuText.subtitleSmMedium.copyWith(
                fontWeight: HabuuWeight.bold,
                color: HabuuTextColors.links,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AuthButton(
          label: 'Iniciar sesión',
          onPressed: _login,
          isLoading: context.select<AuthProvider, bool>((a) => a.isLoading),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'o inicia sesión con:',
            style: HabuuText.subtitleSmMedium.copyWith(
              fontWeight: HabuuWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SocialLoginButtons(),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.register),
            child: Text.rich(
              TextSpan(
                text: '¿No tienes cuenta? ',
                style: HabuuText.subtitleSmMedium.copyWith(
                  fontWeight: HabuuWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'Registrarse',
                    style: TextStyle(color: HabuuTextColors.links),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
