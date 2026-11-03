import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/routes.dart';
import '../../../config/theme/tokens.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/habuu_shell.dart';
import '../landing/landing_screen.dart';
import '../landing/onboarding_screen.dart';
import 'verification/account_verified_screen.dart';

/// Primera pantalla de la app. Escucha la sesión y decide qué mostrar:
/// cargando, la landing (sin sesión), la bienvenida o el home. Nadie navega
/// al home a mano; basta con que cambie la sesión.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.home = const HabuuShell()});

  /// Lo que se ve con la sesión iniciada. Las pruebas pasan otra pantalla
  /// para no depender de los datos de Supabase.
  final Widget home;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Se crea una vez: si se pidiera en build(), cada reconstrucción volvería
  // a suscribirse y se vería el indicador de carga otra vez.
  late final Stream<AppUser?> _session = context
      .read<AuthRepository>()
      .authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _session,
      builder: (context, snapshot) {
        // Mientras Supabase lee la sesión guardada no se muestra el login,
        // para que no parpadee al abrir la app ya con sesión.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingView();
        }

        final auth = context.watch<AuthProvider>();
        // La sesión temporal de "recuperar contraseña" no deja entrar.
        final signedIn = snapshot.data != null && !auth.isRecoveringPassword;

        if (!signedIn) {
          return LandingPage(
            onLogin: () => Navigator.of(context).pushNamed(AppRoutes.login),
            onCreateAccount: () =>
                Navigator.of(context).pushNamed(AppRoutes.register),
          );
        }
        if (auth.showWelcome) {
          return _WelcomeFlow(onDone: auth.finishWelcome);
        }
        return widget.home;
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: HabuuColors.white100,
      body: Center(
        child: CircularProgressIndicator(
          color: HabuuColors.primary500,
          semanticsLabel: 'Cargando',
        ),
      ),
    );
  }
}

/// "Cuenta verificada" y después el onboarding, solo al crear la cuenta.
class _WelcomeFlow extends StatefulWidget {
  const _WelcomeFlow({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_WelcomeFlow> createState() => _WelcomeFlowState();
}

class _WelcomeFlowState extends State<_WelcomeFlow> {
  bool _showOnboarding = false;

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) return OnboardingScreen(onFinish: widget.onDone);
    return AccountVerifiedScreen(
      onFinished: (_) => setState(() => _showOnboarding = true),
    );
  }
}
