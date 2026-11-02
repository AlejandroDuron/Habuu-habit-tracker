import 'package:flutter/foundation.dart';

import '../../data/datasources/home_data_source.dart';
import '../../data/models/today_habit.dart';
import '../../data/repositories/home_repository.dart';
import '../../services/photo_compressor.dart';
import 'streaks_provider.dart';
import 'trophies_provider.dart';/// En qué punto está la carga del Home.
enum HomeStatus { loading, ready, error, signedOut }

class HomeProvider extends ChangeNotifier {
  /// [clock] dice qué día es hoy; se puede cambiar para probar otros días.
  /// [trophies] es opcional: si se pasa, se evalúan trofeos al marcar hábitos.
  HomeProvider(
    this._repository, {
    DateTime Function()? clock,
    TrophiesProvider? trophies,
  })  : _clock = clock ?? DateTime.now,
        _trophies = trophies;

  final HomeRepository _repository;
  final DateTime Function() _clock;

  /// Referencia al provider de trofeos para disparar evaluaciones.
  /// Es `late` para permitir inyección posterior (cuando se construye en AppProviders).
  TrophiesProvider? _trophies;

  /// Permite que [AppProviders] inyecte el provider de trofeos después de crearlo.
  // ignore: use_setters_to_change_properties
  void setTrophiesProvider(TrophiesProvider trophies) {
    _trophies = trophies;
  }

  HomeStatus _status = HomeStatus.loading;
  List<TodayHabit> _habits = [];
  String? _errorMessage;

  /// Hábitos que se están guardando para evitar doble tap.
  final Set<String> _saving = {};

  HomeStatus get status => _status;
  List<TodayHabit> get habits => List.unmodifiable(_habits);
  String? get errorMessage => _errorMessage;

  /// Froggy está despierta si hoy ya se cumplió al menos un hábito.
  bool get frogAwake => HomeRepository.isFrogAwake(_habits);

  // ── Carga ────────────────────────────────────────────────────────────────

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

  // ── Marcar hábito ────────────────────────────────────────────────────────

  /// Marca un hábito como cumplido hoy, con [photo] como evidencia si viene.
  /// Devuelve null si salió bien, o el mensaje de error para mostrarlo.
  Future<String?> markDone(String habitId, {Uint8List? photo}) async {
    if (!_saving.add(habitId)) return null;

    try {
      final today = _clock();
      final log = photo == null
          ? await _repository.markDone(habitId, today)
          : await _repository.markDoneWithPhoto(habitId, today, photo);

      // Actualiza la lista en memoria con el nuevo log.
      _habits = [
        for (final h in _habits)
          h.habit.id == habitId ? TodayHabit(habit: h.habit, log: log) : h,
      ];

      // Evalúa si el día quedó completo y registra en daily_summaries.
      final allDone = _habits.every((h) => h.isDone);
      _repository.checkAndMarkDayComplete(today, _habits);

      notifyListeners();

      // Evalúa trofeos relacionados con el día y la racha.
      _evaluateTrophiesAfterMark(allDone: allDone);

      return null;
    } on NotSignedInException {
      return 'Inicia sesión para guardar tu progreso';
    } on SkipNotAllowedException catch (e) {
      return e.toString();
    } on HomeDataException catch (e) {
      return e.message;
    } on PhotoCompressionException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Error inesperado al marcar un hábito: $e');
      return 'Algo salió mal. Inténtalo de nuevo.';
    } finally {
      _saving.remove(habitId);
    }
  }

  // ── Trofeos ──────────────────────────────────────────────────────────────

  /// Dispara las comprobaciones de trofeos que dependen de completar hábitos.
  /// Se ejecuta en background (fire-and-forget): los errores no llegan al usuario.
  void _evaluateTrophiesAfterMark({required bool allDone}) {
    final trophies = _trophies;
    if (trophies == null) return;

    // Trofeo de día completado.
    trophies.checkDayCompleted(allDone: allDone).catchError(
      (e) => debugPrint('Error al evaluar day_completed: $e'),
    );

    // Si el día quedó completo, evaluamos trofeos adicionales.
    if (allDone) {
      trophies.checkDiscipline().catchError(
        (e) => debugPrint('Error al evaluar discipline: $e'),
      );
      trophies.checkStreak300().catchError(
        (e) => debugPrint('Error al evaluar streak_300: $e'),
      );

      // Recalcular la racha localmente para evaluar streak_7 / streak_14.
      // Se cuenta cuántos días consecutivos (hacia atrás desde hoy) existen
      // en _recentCompletedDays. Esto evita una llamada extra a la DB para
      // el caso común; la pantalla de Rachas hará su propia carga completa.
      _evaluateStreakTrophiesLocally(trophies);
    }
  }

  /// Estima la racha consecutiva a partir de los días ya conocidos en memoria
  /// y evalúa los trofeos de racha (streak_7, streak_14, streak_300).
  ///
  /// Solo llama a [checkStreakTrophies] si puede estimar un valor > 0.
  /// Si los datos locales no son suficientes, silencia el error.
  void _evaluateStreakTrophiesLocally(TrophiesProvider trophies) {
    // Pedimos la racha al StreaksProvider si está disponible; si no,
    // usamos una estimación mínima de 1 (el día de hoy quedó completo).
    final streaks = _streaksProvider;
    final currentStreak =
        (streaks != null && streaks.currentStreak > 0)
            ? streaks.currentStreak
            : 1;

    trophies.checkStreakTrophies(currentStreak: currentStreak).catchError(
      (e) => debugPrint('Error al evaluar trofeos de racha: $e'),
    );
  }

  // ── Inyección de StreaksProvider ─────────────────────────────────────────

  StreaksProvider? _streaksProvider;

  /// Permite que [AppProviders] inyecte el provider de rachas para leer
  /// la racha actual al evaluar trofeos de streak.
  // ignore: use_setters_to_change_properties
  void setStreaksProvider(StreaksProvider streaks) {
    _streaksProvider = streaks;
  }
}
