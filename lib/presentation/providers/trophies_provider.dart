import 'package:flutter/foundation.dart';

import '../../data/models/trophy.dart';
import '../../data/repositories/trophy_repository.dart';

export '../../data/repositories/trophy_repository.dart' show TrophyKeys;

enum TrophiesStatus { initial, loading, ready, error }

class TrophiesProvider extends ChangeNotifier {
  TrophiesProvider(this._repository);

  final TrophyRepository _repository;

  TrophiesStatus _status = TrophiesStatus.initial;
  List<EarnedTrophy> _earned = [];
  List<Trophy> _locked = [];
  String? _errorMessage;

  /// Trofeos ganados en la última evaluación; la UI puede mostrarlos
  /// como notificación y luego llamar a [clearNewlyEarned].
  final List<EarnedTrophy> _newlyEarned = [];

  TrophiesStatus get status => _status;
  List<EarnedTrophy> get earned => List.unmodifiable(_earned);
  List<Trophy> get locked => List.unmodifiable(_locked);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TrophiesStatus.loading;

  /// Trofeos ganados recién (desde la última llamada a [clearNewlyEarned]).
  List<EarnedTrophy> get newlyEarned => List.unmodifiable(_newlyEarned);

  int get earnedCount => _earned.length;
  EarnedTrophy? get latestEarned => _earned.isNotEmpty ? _earned.first : null;

  // ── Carga ────────────────────────────────────────────────────────────────

  Future<void> loadTrophies() async {
    if (_status == TrophiesStatus.loading) return;

    _status = TrophiesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getTrophies();
      _earned = result.earned;
      _locked = result.locked;
      _status = TrophiesStatus.ready;
    } catch (e) {
      _errorMessage = 'No se pudieron cargar los trofeos';
      _status = TrophiesStatus.error;
      debugPrint('Error al cargar trofeos: $e');
    } finally {
      notifyListeners();
    }
  }

  // ── Evaluación de trofeos ────────────────────────────────────────────────

  /// Verifica si se completó el día y otorga [day_completed] si corresponde.
  Future<void> checkDayCompleted({required bool allDone}) async {
    final trophy = await _repository.checkDayCompleted(allDone: allDone);
    _registerIfEarned(trophy);
  }

  /// Verifica la racha y otorga [streak_7], [streak_14] y/o [streak_300].
  Future<void> checkStreakTrophies({required int currentStreak}) async {
    final trophies = await _repository.checkStreakTrophies(
      currentStreak: currentStreak,
    );
    for (final t in trophies) {
      _registerIfEarned(t);
    }
  }

  /// Otorga [new_habits] la primera vez que el usuario registra un hábito.
  Future<void> checkNewHabit() async {
    final trophy = await _repository.checkNewHabit();
    _registerIfEarned(trophy);
  }

  /// Verifica si el usuario lleva al menos un mes en Habuu.
  Future<void> checkOneMonth({required DateTime firstHabitDate}) async {
    final trophy =
        await _repository.checkOneMonth(firstHabitDate: firstHabitDate);
    _registerIfEarned(trophy);
  }

  /// Verifica 90 días de consistencia total.
  Future<void> checkDiscipline() async {
    final trophy = await _repository.checkDiscipline();
    _registerIfEarned(trophy);
  }

  /// Verifica si el usuario acumula 300 días completados en total.
  Future<void> checkStreak300() async {
    final trophy = await _repository.checkStreak300();
    _registerIfEarned(trophy);
  }

  /// Limpia la lista de trofeos recién ganados (llamar tras mostrar la notif).
  void clearNewlyEarned() {
    if (_newlyEarned.isEmpty) return;
    _newlyEarned.clear();
    notifyListeners();
  }

  // ── Helpers privados ─────────────────────────────────────────────────────

  /// Si [trophy] no es null, lo mueve de locked→earned y notifica.
  void _registerIfEarned(EarnedTrophy? trophy) {
    if (trophy == null) return;

    _newlyEarned.add(trophy);

    // Actualiza la lista en memoria sin recargar desde la red.
    _locked = _locked.where((t) => t.id != trophy.trophy.id).toList();
    if (!_earned.any((e) => e.trophy.id == trophy.trophy.id)) {
      _earned = [trophy, ..._earned];
    }

    notifyListeners();
  }
}
