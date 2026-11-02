import 'package:flutter/widgets.dart';
import 'package:habuu/presentation/screens/auth/login/login_screen.dart';
import 'package:habuu/presentation/screens/auth/recover/recover_password_screen.dart';
import 'package:habuu/presentation/screens/auth/register/register_screen.dart';
import 'package:habuu/presentation/screens/landing/landing_screen.dart';

abstract final class AppRoutes {
  static const landing = '/landing';
  static const login = '/login';
  static const register = '/register';
  static const recover = '/recover';

  static Map<String, WidgetBuilder> get routes => {
        landing: (context) => LandingPage(
              onLogin: () => Navigator.of(context).pushNamed(login),
              onCreateAccount: () => Navigator.of(context).pushNamed(register),
            ),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        recover: (_) => const RecoverPasswordScreen(),
      };
}
