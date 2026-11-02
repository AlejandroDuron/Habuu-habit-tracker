import 'package:flutter/foundation.dart';

import '../../data/models/trophy.dart';
import '../../data/repositories/trophy_repository.dart';

enum TrophiesStatus { initial, loading, ready, error }

class TrophiesProvider extends ChangeNotifier {
  TrophiesProvider(this._repository);

  final TrophyRepository _repository;

  TrophiesStatus _status = TrophiesStatus.initial;
  List<EarnedTrophy> _earned = [];
  List<Trophy> _locked = [];
  String? _errorMessage;

  TrophiesStatus get status => _status;
  List<EarnedTrophy> get earned => List.unmodifiable(_earned);
  List<Trophy> get locked => List.unmodifiable(_locked);
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == TrophiesStatus.loading;

  /// Cuántos trofeos ganados tiene el usuario.
  int get earnedCount => _earned.length;

  /// El trofeo ganado más recientemente, o null si no hay ninguno.
  EarnedTrophy? get latestEarned =>
      _earned.isNotEmpty ? _earned.first : null;

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
}
