import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '/data/datasources/in_memory_habit_data_source.dart';
import '/data/repositories/habit_repository.dart';
import '/presentation/providers/habits_provider.dart';
import '/presentation/screens/landing/landing_screen.dart';
import '/presentation/widgets/shared/habuu_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> _navigatorKey =
    GlobalKey<NavigatorState>();
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_KEY'),
  );xs
 
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
 
  runApp(
    // Ponemos el provider ARRIBA de toda la app,
    // para que cualquier pantalla, incluso las que se abren con
    // Navigator.push, pueda leer los hábitos
    ChangeNotifierProvider(
      // Este es el ÚNICO lugar donde decidimos de dónde salen los datos.
      // Hoy es en memoria; después usamos supa por la otra implementación
      // y ninguna pantalla se toca
      create: (_) => HabitsProvider(
        HabitRepository(InMemoryHabitDataSource()),
      )..loadHabits(),
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
      home: LandingPage(
        onLogin: () {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (_) => const HabuuShell(),
            ),
          );
        },
        onCreateAccount: () {
        },
      ),
    );
  }
}