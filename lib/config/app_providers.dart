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
import '/services/notification_service.dart';
  
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child, this.reminders});

  final Widget child;

  /// Servicio de notificaciones que se crea en main(). Si no se pasa, la
  /// app funciona igual pero sin recordatorios
  final HabitReminderScheduler? reminders;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    final dailySummaryDs = SupabaseDailySummaryDataSource(supabase);
    final trophyDs = SupabaseTrophyDataSource(supabase);

    return MultiProvider(
      providers: [
        //TrophiesProvider no depende de nadie, por eso es un ChangeNotifierProvider
        ChangeNotifierProvider(
          create: (_) => TrophiesProvider(
            TrophyRepository(trophyDs, dailySummary: dailySummaryDs),
          ),
        ),

        //HabitsProvider depende de trofeos, por eso es un ChangeNotifierProxyProvider
        ChangeNotifierProxyProvider<TrophiesProvider, HabitsProvider>(
          create: (_) => HabitsProvider(
            HabitRepository(SupabaseHabitDataSource(supabase)),
            reminders: reminders,
          )..loadHabits(),
          update: (_, trophies, habits) {
            habits!.setTrophiesProvider(trophies);
            return habits;
          },
        ),

        //StreaksProvider depende de trofeos, por eso es un ChangeNotifierProxyProvider
        ChangeNotifierProxyProvider<TrophiesProvider, StreaksProvider>(
          create: (_) => StreaksProvider(
            StreakRepository(SupabaseStreakDataSource(supabase)),
          ),
          update: (_, trophies, streaks) {
            streaks!.setTrophiesProvider(trophies);
            return streaks;
          },
        ),
        //home provider depende de trofeos y rachas, por eso es un ChangeNotifierProxyProvider2
        ChangeNotifierProxyProvider2<
          TrophiesProvider,
          StreaksProvider,
          HomeProvider
        >(
          create: (_) => HomeProvider(
            HomeRepository(
              SupabaseHomeDataSource(supabase),
              SupabaseEvidenceDataSource(supabase),
              dailySummaryDs,
            ),
          ),
          update: (context, trophies, streaks, home) {
            // Lee HabitsProvider del árbol para inyectarlo en HomeProvider
            final habits = context.read<HabitsProvider>();
            home!
              ..setTrophiesProvider(trophies)
              ..setStreaksProvider(streaks)
              ..setHabitsProvider(habits);
            return home;
          },
        ),

        //Authprovider para manejar el estado de autenticación del usuario
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: child,
    );
  }
}