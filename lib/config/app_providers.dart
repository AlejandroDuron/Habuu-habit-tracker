import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/data/datasources/supabase_daily_summary_data_source.dart';
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

/// Construye el árbol de providers de la app.
///
/// Separar esto de [main] mantiene el archivo de entrada limpio y
/// facilita intercambiar datasources reales por fakes en tests.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HabitsProvider(
            HabitRepository(SupabaseHabitDataSource(supabase)),
          )..loadHabits(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            HomeRepository(
              SupabaseHomeDataSource(supabase),
              SupabaseEvidenceDataSource(supabase),
              SupabaseDailySummaryDataSource(supabase),
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
      child: child,
    );
  }
}
