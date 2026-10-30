import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '/config/routes.dart'; // AUTH
import '/data/datasources/in_memory_habit_data_source.dart';
import '/data/repositories/habit_repository.dart';
import '/presentation/providers/auth_provider.dart'; // AUTH
import '/presentation/providers/habits_provider.dart';
import '/presentation/screens/landing/landing_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> _navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_KEY'),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HabitsProvider(
            HabitRepository(InMemoryHabitDataSource()),
          )..loadHabits(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const HabuuApp(),
    ),
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