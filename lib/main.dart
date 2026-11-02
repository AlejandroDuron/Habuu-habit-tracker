import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/config/routes.dart';
import '/data/datasources/supabase_evidence_data_source.dart';
import '/data/datasources/supabase_habit_data_source.dart';
import '/data/datasources/supabase_home_data_source.dart';
import '/data/datasources/supabase_streak_data_source.dart';
import '/data/datasources/supabase_trophy_data_source.dart';
import '/data/repositories/habit_repository.dart';
import '/data/repositories/home_repository.dart';
import '/data/repositories/streak_repository.dart';
import '/data/repositories/trophy_repository.dart';
import '/presentation/providers/auth_provider.dart';
import '/presentation/providers/habits_provider.dart';
import '/presentation/providers/home_provider.dart';
import '/presentation/providers/streaks_provider.dart';
import '/presentation/providers/trophies_provider.dart';
import '/presentation/screens/landing/landing_screen.dart';
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

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final supabase = Supabase.instance.client;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              HabitsProvider(HabitRepository(SupabaseHabitDataSource(supabase)))
                ..loadHabits(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            HomeRepository(
              SupabaseHomeDataSource(supabase),
              SupabaseEvidenceDataSource(supabase),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StreaksProvider(
            StreakRepository(SupabaseStreakDataSource(supabase)),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TrophiesProvider(
            TrophyRepository(SupabaseTrophyDataSource(supabase)),
          ),
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
