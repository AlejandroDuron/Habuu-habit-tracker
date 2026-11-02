import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/config/app_providers.dart';
import '/config/routes.dart';
import '/presentation/screens/landing/landing_screen.dart';
import '/services/notification_service.dart';
import '/utils/dev_session.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_KEY'),
  );
  await signInForDevelopment(Supabase.instance.client);
  
  final reminders = LocalNotificationService();
  try {
    await reminders.init();
  } catch (e) {

    debugPrint('No se pudieron iniciar las notificaciones: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(AppProviders(reminders: reminders, child: const HabuuApp()));

  reminders.requestPermission().catchError(
    (e) => debugPrint('No se pudo pedir permiso de notificaciones: $e'),
  );
}

class HabuuApp extends StatelessWidget {
  const HabuuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Habuu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          surface: Colors.white,
        ),
      ),
      routes: AppRoutes.routes,
      home: LandingPage(
        onLogin: () => _navigatorKey.currentState?.pushNamed(AppRoutes.login),
        onCreateAccount: () =>
            _navigatorKey.currentState?.pushNamed(AppRoutes.register),
      ),
    );
  }
}