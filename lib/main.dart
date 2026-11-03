import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/config/app_providers.dart';
import '/config/routes.dart';
import '/data/datasources/secure_session_storage.dart';
import '/data/repositories/supabase_auth_repository.dart';
import '/presentation/screens/auth/auth_gate.dart';
import '/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: const String.fromEnvironment('SUPABASE_KEY'),
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(
        // La misma clave que usaría Supabase con SharedPreferences
        persistSessionKey:
            'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token',
      ),
    ),
  );
  final authRepository = SupabaseAuthRepository(Supabase.instance.client.auth);

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

  runApp(
    AppProviders(
      authRepository: authRepository,
      reminders: reminders,
      child: const HabuuApp(),
    ),
  );

  reminders.requestPermission().catchError(
    (e) => debugPrint('No se pudo pedir permiso de notificaciones: $e'),
  );
}

class HabuuApp extends StatelessWidget {
  const HabuuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const AuthGate(),
    );
  }
}
