import '../datasources/daily_summary_data_source.dart';
import '../datasources/trophy_data_source.dart';
import '../models/trophy.dart';

/// Claves de los trofeos tal como están en la tabla `trophies`.
abstract final class TrophyKeys {
  static const dayCompleted = 'day_completed';
  static const streak7 = 'streak_7';
  static const newHabits = 'new_habits';
  static const streak14 = 'streak_14';
  static const discipline = 'discipline';
  static const oneMonth = 'one_month';
  static const streak300 = 'streak_300';
}

class TrophyRepository {
  TrophyRepository(this._dataSource, {DailySummaryDataSource? dailySummary})
    : _dailySummary = dailySummary;

  final TrophyDataSource _dataSource;

  /// Opcional: permite consultar días completados para trofeos de consistencia.
  final DailySummaryDataSource? _dailySummary;

  /// Trae todos los trofeos y los separa entre ganados y pendientes.
  Future<({List<EarnedTrophy> earned, List<Trophy> locked})>
  getTrophies() async {
    final results = await Future.wait([
      _dataSource.getAllTrophies(),
      _dataSource.getEarnedTrophies(),
    ]);

    final all = results[0] as List<Trophy>;
    final earned = results[1] as List<EarnedTrophy>;

    final earnedIds = earned.map((e) => e.trophy.id).toSet();
    final locked = all.where((t) => !earnedIds.contains(t.id)).toList();

    return (earned: earned, locked: locked);
  }

  // ── Evaluación de trofeos ────────────────────────────────────────────────

  /// Intenta otorgar el trofeo [day_completed] si el día quedó completamente
  /// hecho. Devuelve el [EarnedTrophy] si se ganó ahora, o null si ya lo
  /// tenía o no se cumple la condición.
  Future<EarnedTrophy?> checkDayCompleted({required bool allDone}) async {
    if (!allDone) return null;
    return _dataSource.awardTrophy(TrophyKeys.dayCompleted);
  }

  /// Intenta otorgar [streak_7] y/o [streak_14] según la racha actual del
  /// usuario, y [streak_300] si tiene al menos 300 días completados acumulados.
  ///
  /// Devuelve la lista de trofeos ganados en esta evaluación (puede ser
  /// vacía, o contener 1-3 trofeos si alcanzó varios umbrales a la vez).
  Future<List<EarnedTrophy>> checkStreakTrophies({
    required int currentStreak,
  }) async {
    final earned = <EarnedTrophy>[];

    if (currentStreak >= 7) {
      final t = await _dataSource.awardTrophy(TrophyKeys.streak7);
      if (t != null) earned.add(t);
    }
    if (currentStreak >= 14) {
      final t = await _dataSource.awardTrophy(TrophyKeys.streak14);
      if (t != null) earned.add(t);
    }

    // streak_300 se evalúa sobre días acumulados totales, no racha consecutiva.
    final t300 = await checkStreak300();
    if (t300 != null) earned.add(t300);

    return earned;
  }

  /// Intenta otorgar [streak_300] si el usuario acumula 300 o más días
  /// completados en toda su historia (no necesariamente consecutivos).
  ///
  /// Requiere que [_dailySummary] esté disponible.
  Future<EarnedTrophy?> checkStreak300() async {
    final summary = _dailySummary;
    if (summary == null) return null;

    final total = await summary.getTotalCompletedDays();
    if (total < 300) return null;
    return _dataSource.awardTrophy(TrophyKeys.streak300);
  }

  /// Intenta otorgar [new_habits] cuando el usuario crea su primer hábito
  /// (o cualquier nuevo hábito; se otorga una sola vez gracias a awardTrophy).
  Future<EarnedTrophy?> checkNewHabit() async {
    return _dataSource.awardTrophy(TrophyKeys.newHabits);
  }

  /// Intenta otorgar [one_month] si el usuario tiene al menos 30 días
  /// desde que creó su primer hábito ([firstHabitDate]).
  Future<EarnedTrophy?> checkOneMonth({
    required DateTime firstHabitDate,
  }) async {
    final monthPassed = DateTime.now().difference(firstHabitDate).inDays >= 30;
    if (!monthPassed) return null;
    return _dataSource.awardTrophy(TrophyKeys.oneMonth);
  }

  /// Intenta otorgar [discipline] si el usuario completó todos sus hábitos
  /// en al menos 60 de los últimos 90 días (≈ 2 de cada 3 días).
  ///
  /// Requiere que [_dailySummary] esté disponible.
  Future<EarnedTrophy?> checkDiscipline() async {
    final summary = _dailySummary;
    if (summary == null) return null;

    final since = DateTime.now().subtract(const Duration(days: 90));
    final completedDays = await summary.getCompletedDays(since: since);

    // 60 de 90 días (~67 % de consistencia) es alcanzable pero exigente.
    if (completedDays.length < 60) return null;
    return _dataSource.awardTrophy(TrophyKeys.discipline);
  }
}
