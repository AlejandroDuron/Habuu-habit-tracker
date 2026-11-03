/// Cómo está Froggy en el estanque del Home.
enum FrogMood {
  /// Hoy no se ha cumplido ningún hábito.
  sleeping,

  /// Se acaba de cumplir un hábito: salta con el signo de exclamación.
  celebrating,

  /// Ya pasó la celebración y hay hábitos cumplidos: descansa despierta.
  resting,
}

/// Cuánto salta Froggy después de cumplir un hábito.
const celebrationDuration = Duration(seconds: 10);

/// Decide cómo está Froggy.
///
/// [awake] es si hoy ya hay algún hábito cumplido y [lastDoneAt] cuándo se
/// cumplió el último. Si fue hace menos de [celebrationDuration], celebra.
FrogMood frogMoodFor({
  required bool awake,
  required DateTime? lastDoneAt,
  required DateTime now,
}) {
  if (!awake) return FrogMood.sleeping;
  if (lastDoneAt != null && now.difference(lastDoneAt) < celebrationDuration) {
    return FrogMood.celebrating;
  }
  return FrogMood.resting;
}
