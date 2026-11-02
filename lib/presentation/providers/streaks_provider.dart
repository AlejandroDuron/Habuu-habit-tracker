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
}
