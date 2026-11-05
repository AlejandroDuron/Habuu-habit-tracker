import 'package:flutter/foundation.dart';

import '../../data/models/streak_data.dart';
import '../../data/repositories/streak_repository.dart';
import 'trophies_provider.dart';

enum StreaksStatus { initial, loading, ready, error }

class StreaksProvider extends ChangeNotifier {
  StreaksProvider(this._repository, {TrophiesProvider? trophies})
      : _trophies = trophies;

  final StreakRepository _repository;

  TrophiesProvider? _trophies;

  // ignore: use_setters_to_change_properties
  void setTrophiesProvider(TrophiesProvider trophies) {
    _trophies = trophies;
  }

  StreaksStatus _status = StreaksStatus.initial;
  StreakData _data = const StreakData.empty();
  String? _errorMessage;

  StreaksStatus get status => _status;
  StreakData get data => _data;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == StreaksStatus.loading;

  int get currentStreak => _data.currentStreak;
  Set<DateTime> get streakDays => _data.streakDays;

  Future<void> loadStreak() async {
    if (_status == StreaksStatus.loading) return;

    _status = StreaksStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _repository.getStreak();
      _status = StreaksStatus.ready;

      // Evalúa trofeos de racha tras cargar.
      _trophies?.checkStreakTrophies(
        currentStreak: _data.currentStreak,
      ).catchError((e) => debugPrint('Error al evaluar trofeos de racha: $e'));
    } catch (e) {
      _errorMessage = 'No se pudo calcular tu racha';
      _status = StreaksStatus.error;
      debugPrint('Error al cargar racha: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Recarga la racha sin pasar por el estado [loading], para que el
  /// [StreakHeader] no se desmonte y no dispare animaciones falsas.
  ///
  /// Pasa [dayJustCompleted] en true cuando el día acaba de completarse,
  /// para que el header sepa que debe animar el salto de Froggy.
  Future<void> refreshSilently({bool dayJustCompleted = false}) async {
    if (_status == StreaksStatus.loading) return;

    try {
      _data = await _repository.getStreak();
      _status = StreaksStatus.ready;
      _lastCompletionWasNew = dayJustCompleted;
      notifyListeners();
      _lastCompletionWasNew = false;
    } catch (e) {
      debugPrint('Error al recargar racha: $e');
    }
  }

  /// true solo durante el rebuild inmediatamente posterior a un día completado.
  /// El [StreakHeader] lo lee para decidir si anima el salto.
  bool _lastCompletionWasNew = false;
  bool get dayJustCompleted => _lastCompletionWasNew;
}
