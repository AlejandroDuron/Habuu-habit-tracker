import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import '/presentation/screens/landing/landing_screen.dart';
import '/presentation/widgets/shared/habuu_shell.dart';

final GlobalKey<NavigatorState> _navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');

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
      navigatorKey: _navigatorKey,
      title: 'Habuu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: LandingPage(
        onLogin: () {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (_) => const HabuuShell(),
            ),
          );
        },
        onCreateAccount: () {
          // TODO: navegar a la pantalla de creación de cuenta.
        },
      ),
    );
  }
}