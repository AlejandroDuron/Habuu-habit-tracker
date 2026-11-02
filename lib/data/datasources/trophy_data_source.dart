import '../models/trophy.dart';

abstract interface class TrophyDataSource {
  /// Todos los trofeos que existen en el sistema (tabla `trophies`).
  Future<List<Trophy>> getAllTrophies();

  /// Trofeos que ya ganó el usuario (tabla `trophies_per_user`).
  Future<List<EarnedTrophy>> getEarnedTrophies();

  /// Otorga el trofeo con [trophyId] al usuario si aún no lo tiene.
  /// Devuelve el [EarnedTrophy] recién creado, o null si ya lo tenía.
  Future<EarnedTrophy?> awardTrophy(String trophyId);
}

/// Error al leer trofeos, con un mensaje listo para mostrarse.
class TrophyDataException implements Exception {
  const TrophyDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
