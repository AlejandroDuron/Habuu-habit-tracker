import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/data/datasources/gemini_edge_function_photo_verifier.dart';
import '/data/datasources/supabase_daily_summary_data_source.dart';
import '/data/datasources/supabase_evidence_data_source.dart';
import '/data/datasources/supabase_habit_data_source.dart';
import '/data/datasources/supabase_home_data_source.dart';
import '/data/datasources/supabase_profile_data_source.dart';
import '/data/datasources/supabase_streak_data_source.dart';
import '/data/datasources/supabase_trophy_data_source.dart';
import '/data/datasources/verification_preferences.dart';
import '/data/repositories/auth_repository.dart';
import '/data/repositories/habit_repository.dart';
import '/data/repositories/home_repository.dart';
import '/data/repositories/profile_repository.dart';
import '/data/repositories/streak_repository.dart';
import '/data/repositories/trophy_repository.dart';
import '/presentation/providers/auth_provider.dart';
import '/presentation/providers/habits_provider.dart';
import '/presentation/providers/home_provider.dart';
import '/presentation/providers/profile_provider.dart';
import '/presentation/providers/streaks_provider.dart';
import '/presentation/providers/trophies_provider.dart';
import '/presentation/providers/verification_settings_provider.dart';
import '/services/notification_service.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.authRepository,
    required this.child,
    this.reminders,
    this.userDataScope,
  });

  final AuthRepository authRepository;
  final Widget child;

  /// Pone los providers de datos del usuario alrededor de la app. Si es null
  /// se usan los de Supabase; las pruebas pasan unos sin red.
  final Widget Function(Widget app)? userDataScope;

  /// Servicio de notificaciones que se crea en main(). Si no se pasa, la
  /// app funciona igual pero sin recordatorios
  final HabitReminderScheduler? reminders;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),

        //Authprovider para manejar el estado de autenticación del usuario
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),

        // Si el usuario aceptó que sus fotos se revisen con Gemini
        ChangeNotifierProvider(
          create: (_) =>
              VerificationSettingsProvider(SharedPrefsVerificationPreferences())
                ..load(),
        ),
      ],
      // Los datos son de un usuario. Al cambiar la sesión se crean de nuevo
      // (y con ellos la navegación), así nadie ve en memoria lo del anterior.
      child: Selector<AuthProvider, String?>(
        selector: (_, auth) => auth.userId,
        builder: (context, userId, app) => userId == null
            ? app!
            : KeyedSubtree(
                key: ValueKey(userId),
                child:
                    userDataScope?.call(app!) ??
                    _UserDataProviders(reminders: reminders, child: app!),
              ),
        child: child,
      ),
    );
  }
}

/// Providers con los hábitos, rachas, trofeos y el home del usuario actual.
class _UserDataProviders extends StatelessWidget {
  const _UserDataProviders({required this.child, required this.reminders});

  final Widget child;
  final HabitReminderScheduler? reminders;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    final dailySummaryDs = SupabaseDailySummaryDataSource(supabase);
    final trophyDs = SupabaseTrophyDataSource(supabase);
    final evidenceDs = SupabaseEvidenceDataSource(supabase);

    return MultiProvider(
      providers: [
        // Se crea (y carga) la primera vez que se abre la pantalla de Usuario.
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            ProfileRepository(SupabaseProfileDataSource(supabase.auth)),
          )..load(),
        ),

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
              evidenceDs,
              dailySummaryDs,
              verifier: GeminiEdgeFunctionPhotoVerifier(supabase.functions),
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
      ],
      child: child,
    );
  }
}
