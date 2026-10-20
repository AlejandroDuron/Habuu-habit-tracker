import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/presentation/screens/home/home_screen.dart';
import '/presentation/screens/landing/landing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const HabuuApp());
}

class HabuuApp extends StatelessWidget {
  const HabuuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habuu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Builder(
        builder: (context) => LandingPage(
          onLogin: () {
            // TODO: navegar a la pantalla de inicio de sesión.
            // Por ahora lleva directo a Home para previsualizarla.
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const HomePage()));
          },
          onCreateAccount: () {
            // TODO: navegar a la pantalla de creación de cuenta
          },
        ),
      ),
    );
  }
}
