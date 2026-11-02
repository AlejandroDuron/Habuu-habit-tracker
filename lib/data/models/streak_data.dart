/// Datos de racha del usuario calculados a partir de `habit_logs`.
class StreakData {
  const StreakData({
    required this.currentStreak,
    required this.streakDays,
  });

  /// Días consecutivos actuales con al menos un hábito completado.
  final int currentStreak;

  /// Conjunto de fechas que forman parte de la racha (para pintar en el calendario).
  final Set<DateTime> streakDays;

  const StreakData.empty()
      : currentStreak = 0,
        streakDays = const {};
}
