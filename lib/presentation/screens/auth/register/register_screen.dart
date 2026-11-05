import 'package:flutter/material.dart';
import 'package:habuu/presentation/providers/auth_provider.dart';
import 'package:habuu/utils/auth_feedback.dart';
import 'package:provider/provider.dart';
import 'package:habuu/config/assets.dart';
import 'package:habuu/config/theme/tokens.dart';
import 'package:habuu/presentation/screens/auth/verification/code_verification_screen.dart';
import 'package:habuu/presentation/widgets/auth/auth_button.dart';
import 'package:habuu/config/routes.dart';
import 'package:habuu/presentation/widgets/auth/auth_scaffold.dart';
import 'package:habuu/presentation/widgets/auth/auth_text_field.dart';
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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
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
    // Sin confirmación de correo la cuenta ya inició sesión y el AuthGate
    // muestra la bienvenida.
    if (!auth.isWaitingForCode) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CodeVerificationScreen(
          title: 'Ingresa código de\nconfirmación',
          buttonLabel: 'Verificar cuenta',
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Correo electrónico',
                controller: _emailController,
                focusNode: _emailFocus,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Contraseña',
                controller: _passwordController,
                focusNode: _passwordFocus,
                hint: AuthTextField.passwordHint,
                obscureText: true,
                helperText: Validators.passwordRules,
                validator: Validators.password,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Confirmar contraseña',
                controller: _confirmController,
                focusNode: _confirmFocus,
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
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.login),
            child: Text.rich(
              TextSpan(
                text: '¿Ya tienes una cuenta? ',
                style: HabuuText.subtitleSmMedium.copyWith(
                  fontWeight: HabuuWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'Iniciar sesión',
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
