import '../models/trophy.dart';

abstract interface class TrophyDataSource {
  /// Todos los trofeos que existen en el sistema (tabla `trophies`).
  Future<List<Trophy>> getAllTrophies();

  /// Trofeos que ya ganó el usuario (tabla `trophies_per_user`).
  Future<List<EarnedTrophy>> getEarnedTrophies();
}

/// Error al leer trofeos, con un mensaje listo para mostrarse.
class TrophyDataException implements Exception {
  const TrophyDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
