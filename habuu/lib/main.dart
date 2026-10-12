import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'landing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
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
      home: LandingPage(
        onLogin: () {
          // TODO: navegar a la pantalla de inicio de sesión
        },
        onCreateAccount: () {
          // TODO: navegar a la pantalla de creación de cuenta
        },
      ),
    );
  }
}
