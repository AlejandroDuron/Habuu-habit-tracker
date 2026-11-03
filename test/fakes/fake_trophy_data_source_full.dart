import 'package:habuu/data/datasources/trophy_data_source.dart';
import 'package:habuu/data/models/trophy.dart';

/// Fuente de trofeos configurable para tests.
///
/// - [allTrophies]: catálogo completo devuelto por [getAllTrophies].
/// - [earnedTrophies]: trofeos ya ganados por el usuario.
/// - [awardedTrophy]: lo que devuelve [awardTrophy] (null = ya tenía el trofeo).
/// - [shouldFail]: si true, todas las operaciones lanzan una excepción.
class FakeTrophyDataSourceFull implements TrophyDataSource {
  FakeTrophyDataSourceFull({
    List<Trophy>? allTrophies,
    List<EarnedTrophy>? earnedTrophies,
    this.awardedTrophy,
    this.shouldFail = false,
  })  : _all = allTrophies ?? _defaultTrophies(),
        _earned = earnedTrophies ?? [];

  final List<Trophy> _all;
  final List<EarnedTrophy> _earned;

  /// Trofeo que devolverá la próxima llamada a [awardTrophy].
  EarnedTrophy? awardedTrophy;

  bool shouldFail;

  /// Historial de ids enviados a [awardTrophy].
  final List<String> awardCalls = [];

  void _failIfNeeded() {
    if (shouldFail) throw Exception('Error simulado de trofeos');
  }

  @override
  Future<List<Trophy>> getAllTrophies() async {
    _failIfNeeded();
    return List.unmodifiable(_all);
  }

  @override
  Future<List<EarnedTrophy>> getEarnedTrophies() async {
    _failIfNeeded();
    return List.unmodifiable(_earned);
  }

  @override
  Future<EarnedTrophy?> awardTrophy(String trophyId) async {
    _failIfNeeded();
    awardCalls.add(trophyId);
    return awardedTrophy;
  }

  // ── Catálogo de trofeos de ejemplo ─────────────────────────────────────

  static List<Trophy> _defaultTrophies() => [
        const Trophy(id: 'day_completed', name: 'Día completado', key: 'day_completed'),
        const Trophy(id: 'streak_7', name: 'Racha de 7 días', key: 'streak_7'),
        const Trophy(id: 'new_habits', name: 'Nuevos hábitos', key: 'new_habits'),
        const Trophy(id: 'streak_14', name: 'Racha de 14 días', key: 'streak_14'),
        const Trophy(id: 'discipline', name: 'Disciplina', key: 'discipline'),
        const Trophy(id: 'one_month', name: 'Un mes con Habuu', key: 'one_month'),
        const Trophy(id: 'streak_300', name: '300 días', key: 'streak_300'),
      ];
}

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Construye un [Trophy] con valores por defecto.
Trophy buildTrophy({
  String id = 'day_completed',
  String name = 'Día completado',
  String? key = 'day_completed',
}) =>
    Trophy(id: id, name: name, key: key);

/// Construye un [EarnedTrophy] con valores por defecto.
EarnedTrophy buildEarnedTrophy({
  Trophy? trophy,
  DateTime? earnedAt,
}) =>
    EarnedTrophy(
      trophy: trophy ?? buildTrophy(),
      earnedAt: earnedAt ?? DateTime(2026, 11, 2),
    );
