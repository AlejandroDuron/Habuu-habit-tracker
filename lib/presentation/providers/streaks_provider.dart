import 'package:flutter/foundation.dart';

import '../../data/models/streak_data.dart';
import '../../data/repositories/streak_repository.dart';

enum StreaksStatus { initial, loading, ready, error }

class StreaksProvider extends ChangeNotifier {
  StreaksProvider(this._repository);

  final StreakRepository _repository;

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
    } catch (e) {
      _errorMessage = 'No se pudo calcular tu racha';
      _status = StreaksStatus.error;
      debugPrint('Error al cargar racha: $e');
    } finally {
      notifyListeners();
    }
  }
}
