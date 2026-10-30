import 'package:flutter/material.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';
import 'package:habuu/utils/auth_feedback.dart';
import 'package:provider/provider.dart';
import 'package:habuu/config/assets.dart';
import 'package:habuu/config/theme/tokens.dart';
import 'package:habuu/presentation/screens/auth/verification/account_verified_screen.dart';
import 'package:habuu/presentation/screens/auth/verification/code_verification_screen.dart';
import 'package:habuu/presentation/screens/landing/onboarding_screen.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:habuu/presentation/widgets/auth/auth_scaffold.dart';
import 'package:habuu/presentation/widgets/auth/auth_text_field.dart';
import 'package:habuu/presentation/widgets/auth/social_login_buttons.dart';
import 'package:habuu/presentation/widgets/shared/habuu_shell.dart';
import 'package:habuu/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!ok) {
      showAuthError(context, auth.errorMessage);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CodeVerificationScreen(
          title: 'Ingresa código de\nconfirmación',
          buttonLabel: 'Verificar cuenta',
          onVerified: _showVerified,
        ),
      ),
    );
  }

  void _showVerified(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AccountVerifiedScreen(onFinished: _showOnboarding),
      ),
    );
  }

  /// Cuenta verificada -> onboarding -> home.
  void _showOnboarding(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (onboardingContext) => OnboardingScreen(
          onFinish: () => _goHome(onboardingContext),
        ),
      ),
      (route) => false,
    );
  }

  void _goHome(BuildContext context) {
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
          'Crear cuenta',
          textAlign: TextAlign.center,
          style: HabuuText.h5ExtraBold,
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: 'Nombre',
                controller: _nameController,
                hint: 'Tu nombre',
                validator: (v) => Validators.notEmpty(v, 'Ingresa tu nombre'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
              ),
              const SizedBox(height: 20),
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
                validator: Validators.password,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Confirmar contraseña',
                controller: _confirmController,
                hint: AuthTextField.passwordHint,
                obscureText: true,
                validator: Validators.confirmPassword(_passwordController),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _register(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        AuthButton(
          label: 'Crear cuenta',
          onPressed: _register,
          isLoading: context.select<AuthProvider, bool>((a) => a.isLoading),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'o continúa con:',
            style: HabuuText.subtitleSmMedium.copyWith(
              fontWeight: HabuuWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SocialLoginButtons(),
      ],
    );
  }
}