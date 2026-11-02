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
///
/// Orden de registro:
///  1. TrophiesProvider (sin dependencias)
///  2. HabitsProvider   (depende de TrophiesProvider)
///  3. StreaksProvider   (depende de TrophiesProvider)
///  4. HomeProvider      (depende de TrophiesProvider + StreaksProvider)
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    final dailySummaryDs = SupabaseDailySummaryDataSource(supabase);
    final trophyDs = SupabaseTrophyDataSource(supabase);

    return MultiProvider(
      providers: [
        // ── TrophiesProvider (primero: los demás dependen de él) ──────────
        ChangeNotifierProvider(
          create: (_) => TrophiesProvider(
            TrophyRepository(
              trophyDs,
              dailySummary: dailySummaryDs,
            ),
          ),
        ),

        // ── HabitsProvider ────────────────────────────────────────────────
        ChangeNotifierProxyProvider<TrophiesProvider, HabitsProvider>(
          create: (_) => HabitsProvider(
            HabitRepository(SupabaseHabitDataSource(supabase)),
          )..loadHabits(),
          update: (_, trophies, habits) {
            habits!.setTrophiesProvider(trophies);
            return habits;
          },
        ),

        // ── StreaksProvider ───────────────────────────────────────────────
        ChangeNotifierProxyProvider<TrophiesProvider, StreaksProvider>(
          create: (_) => StreaksProvider(
            StreakRepository(SupabaseStreakDataSource(supabase)),
          ),
          update: (_, trophies, streaks) {
            streaks!.setTrophiesProvider(trophies);
            return streaks;
          },
        ),

        // ── HomeProvider ──────────────────────────────────────────────────
        // Depende de TrophiesProvider (day_completed, discipline, etc.)
        // y de StreaksProvider (leer racha actual al evaluar streak_7/14).
        // También se conecta con HabitsProvider para sincronización
        // bidireccional: cambios en hábitos recargan el Home, y marcar
        // hábitos en el Home actualiza los logs en HabitsList.
        ChangeNotifierProxyProvider2<TrophiesProvider, StreaksProvider,
            HomeProvider>(
          create: (_) => HomeProvider(
            HomeRepository(
              SupabaseHomeDataSource(supabase),
              SupabaseEvidenceDataSource(supabase),
              dailySummaryDs,
            ),
          ),
          update: (context, trophies, streaks, home) {
            // Lee HabitsProvider del árbol para inyectarlo en HomeProvider.
            final habits = context.read<HabitsProvider>();
            home!
              ..setTrophiesProvider(trophies)
              ..setStreaksProvider(streaks)
              ..setHabitsProvider(habits);
            return home;
          },
        ),

        // ── AuthProvider ──────────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: child,
    );
  }
}
