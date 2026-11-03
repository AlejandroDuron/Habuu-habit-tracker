/// Trofeo tal como viene de la base de datos (tabla `trophies`).
class Trophy {
  const Trophy({required this.id, required this.name, this.key});

  /// `trophy_id` — clave de texto (ej: "day_completed").
  final String id;

  /// `trophy_name` — nombre legible (ej: "Día completado").
  final String name;

  /// `trophy_key` — clave de imagen/asset (puede ser null).
  final String? key;

  factory Trophy.fromMap(Map<String, dynamic> map) {
    return Trophy(
      id: map['trophy_id'] as String,
      name: map['trophy_name'] as String,
      key: map['trophy_key'] as String?,
    );
  }
}

/// Trofeo ganado por el usuario: une el trofeo con la fecha en que lo ganó.
class EarnedTrophy {
  const EarnedTrophy({required this.trophy, required this.earnedAt});

  final Trophy trophy;
  final DateTime earnedAt;

  factory EarnedTrophy.fromMap(Map<String, dynamic> map, Trophy trophy) {
    return EarnedTrophy(
      trophy: trophy,
      earnedAt: DateTime.parse(map['earned_at'] as String),
    );
  }
}
