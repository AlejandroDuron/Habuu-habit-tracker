import 'package:flutter/foundation.dart';

import '../../data/datasources/home_data_source.dart';
import '../../data/models/today_habit.dart';
import '../../data/repositories/home_repository.dart';

/// En qué punto está la carga del Home.
enum HomeStatus { loading, ready, error, signedOut }

class HomeProvider extends ChangeNotifier {
  /// [clock] dice qué día es hoy; se puede cambiar para probar otros días.
  HomeProvider(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final HomeRepository _repository;
  final DateTime Function() _clock;

  HomeStatus _status = HomeStatus.loading;
  List<TodayHabit> _habits = [];
  String? _errorMessage;

  /// Hábitos que se están guardando, para no guardarlos dos veces si el
  /// usuario toca el botón varias veces seguidas.
  final Set<String> _saving = {};

  HomeStatus get status => _status;
  List<TodayHabit> get habits => List.unmodifiable(_habits);
  String? get errorMessage => _errorMessage;

  /// Froggy está despierta si hoy ya se cumplió al menos un hábito.
  bool get frogAwake => HomeRepository.isFrogAwake(_habits);

  /// Trae los hábitos que tocan hoy.
  Future<void> load() async {
    _status = HomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _habits = await _repository.getHabitsFor(_clock());
      _status = HomeStatus.ready;
    } on NotSignedInException {
      _habits = [];
      _status = HomeStatus.signedOut;
    } on HomeDataException catch (e) {
      _errorMessage = e.message;
      _status = HomeStatus.error;
    } catch (e) {
      debugPrint('Error inesperado al cargar el Home: $e');
      _errorMessage = 'Algo salió mal. Inténtalo de nuevo.';
      _status = HomeStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Marca un hábito como cumplido hoy. Devuelve null si salió bien, o el
  /// mensaje de error para mostrarlo.
  Future<String?> markDone(String habitId, {String? evidencePath}) async {
    if (!_saving.add(habitId)) return null;

    try {
      final log = await _repository.markDone(
        habitId,
        _clock(),
        evidencePath: evidencePath,
      );
      _habits = [
        for (final h in _habits)
          h.habit.id == habitId ? TodayHabit(habit: h.habit, log: log) : h,
      ];
      notifyListeners();
      return null;
    } on NotSignedInException {
      return 'Inicia sesión para guardar tu progreso';
    } on HomeDataException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Error inesperado al marcar un hábito: $e');
      return 'Algo salió mal. Inténtalo de nuevo.';
    } finally {
      _saving.remove(habitId);
    }
  }
}
