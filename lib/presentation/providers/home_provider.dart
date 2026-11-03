import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/datasources/habit_photo_verifier.dart';
import '../../data/datasources/home_data_source.dart';
import '../../data/models/habit_log.dart';
import '../../data/models/home_habit.dart';
import '../../data/models/today_habit.dart';
import '../../data/models/verification_result.dart';
import '../../data/repositories/home_repository.dart';
import '../../services/photo_compressor.dart';
import '../models/home/evidence_check.dart';
import 'habits_provider.dart';
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

  DateTime? _lastDoneAt;

  /// Cuándo se cumplió el último hábito mientras la app estaba abierta.
  /// Con esto Froggy sabe si le toca celebrar.
  DateTime? get lastDoneAt => _lastDoneAt;

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
      _remember(log, photo);
      _applyLog(habitId, log);
      return null;
    } catch (e) {
      return _messageFor(e);
    } finally {
      _saving.remove(habitId);
    }
  }

  /// Pone el nuevo registro en la lista y avisa a lo que depende de él.
  void _applyLog(String habitId, HabitLog log) {
    final today = _clock();

    // Actualiza la lista en memoria con el nuevo log.
    _habits = [
      for (final h in _habits)
        h.habit.id == habitId ? TodayHabit(habit: h.habit, log: log) : h,
    ];

    // Evalúa si el día quedó completo y registra en daily_summaries.
    final allDone = _habits.every((h) => h.isDone);
    _repository.checkAndMarkDayComplete(today, _habits);

    // Omitir un hábito no cuenta como cumplirlo.
    if (log.isDone) _lastDoneAt = DateTime.now();

    notifyListeners();

    // Evalúa trofeos relacionados con el día y la racha.
    _evaluateTrophiesAfterMark(allDone: allDone);

    // Sincroniza: el HabitsList necesita saber el nuevo estado del log.
    _habitsProvider?.reloadLogStatuses();
  }

  String _messageFor(Object e) {
    switch (e) {
      case NotSignedInException():
        return 'Inicia sesión para guardar tu progreso';
      case SkipNotAllowedException():
        return e.toString();
      case HomeDataException(:final message):
        return message;
      case PhotoCompressionException(:final message):
        return message;
      default:
        debugPrint('Error inesperado al marcar un hábito: $e');
        return 'Algo salió mal. Inténtalo de nuevo.';
    }
  }

  // ── Verificar la foto ────────────────────────────────────────────────────

  /// Foto de cada hábito que se está revisando o ya se revisó.
  final Map<String, EvidenceCheck> _checks = {};

  /// Revisiones cuyo panel se cerró antes de que llegara la respuesta.
  final Set<int> _abandoned = {};
  int _nextCheckId = 0;

  EvidenceCheck? evidenceCheckFor(String habitId) => _checks[habitId];

  /// Sube la foto y la manda a revisar. El hábito se marca solo si la foto
  /// coincide; la revisión sigue sola después de que esto termina.
  /// Devuelve el mensaje de error si no se pudo subir.
  Future<String?> submitEvidence(String habitId, Uint8List photo) async {
    if (!_saving.add(habitId)) return null;

    try {
      final path = await _repository.uploadEvidence(habitId, _clock(), photo);
      final check = EvidenceCheck(
        id: _nextCheckId++,
        photo: photo,
        photoPath: path,
        status: VerificationStatus.verificando,
      );
      _checks[habitId] = check;
      notifyListeners();

      unawaited(_verify(habitId, check));
      return null;
    } catch (e) {
      return _messageFor(e);
    } finally {
      _saving.remove(habitId);
    }
  }

  /// Vuelve a mandar a revisar la foto que no se pudo verificar.
  void retryVerification(String habitId) {
    final check = _checks[habitId];
    if (check == null || check.status != VerificationStatus.noSePudo) return;

    final retry = EvidenceCheck(
      id: _nextCheckId++,
      photo: check.photo,
      photoPath: check.photoPath,
      status: VerificationStatus.verificando,
    );
    _checks[habitId] = retry;
    notifyListeners();

    unawaited(_verify(habitId, retry));
  }

  /// Si no se pudo verificar (sin internet, sin cuota...), deja marcar el
  /// hábito con la foto que ya está subida.
  Future<String?> saveWithoutVerification(String habitId) async {
    final check = _checks[habitId];
    if (check == null || check.status != VerificationStatus.noSePudo) {
      return null;
    }
    if (!_saving.add(habitId)) return null;

    try {
      final error = await _saveEvidenceLog(habitId, check);
      if (error == null) {
        _checks.remove(habitId);
        notifyListeners();
      }
      return error;
    } finally {
      _saving.remove(habitId);
    }
  }

  /// Se cerró el panel. Si la foto no terminó en un registro, se borra.
  void dismissEvidence(String habitId) {
    final check = _checks.remove(habitId);
    if (check == null) return;
    notifyListeners();

    switch (check.status) {
      case VerificationStatus.verificando:
        // Se decide qué hacer con la foto cuando llegue la respuesta.
        _abandoned.add(check.id);
      case VerificationStatus.verificado:
        break;
      case VerificationStatus.noConfirmado || VerificationStatus.noSePudo:
        unawaited(_repository.discardEvidence(check.photoPath));
    }
  }

  Future<void> _verify(String habitId, EvidenceCheck check) async {
    VerificationResult? result;
    String? error;

    final habit = _findHabit(habitId);
    if (habit == null) {
      error = 'Ese hábito ya no está en tu lista';
    } else {
      try {
        result = await _repository.verifyEvidence(check.photoPath, habit);
      } on VerificationException catch (e) {
        error = e.message;
      } catch (e) {
        debugPrint('Error inesperado al verificar la foto: ${e.runtimeType}');
        error = 'No se pudo verificar la foto.';
      }
    }

    final abandoned = _abandoned.remove(check.id);
    // Si mientras tanto se mandó otra foto, esta respuesta ya no sirve.
    if (!abandoned && !_isCurrent(habitId, check)) return;

    if (result != null && result.coincide) {
      // Aunque el panel ya esté cerrado, la foto sirve: se marca igual.
      final saveError = await _saveEvidenceLog(habitId, check);
      if (abandoned || !_isCurrent(habitId, check)) return;
      _checks[habitId] = saveError == null
          ? check.copyWith(
              status: VerificationStatus.verificado,
              result: result,
            )
          : check.copyWith(
              status: VerificationStatus.noSePudo,
              errorMessage: saveError,
            );
      notifyListeners();
      return;
    }

    if (abandoned) {
      // Se borra, salvo que ya haya otra foto en la misma ruta.
      if (!_checks.containsKey(habitId)) {
        unawaited(_repository.discardEvidence(check.photoPath));
      }
      return;
    }

    _checks[habitId] = result != null
        ? check.copyWith(
            status: VerificationStatus.noConfirmado,
            result: result,
          )
        : check.copyWith(
            status: VerificationStatus.noSePudo,
            errorMessage: error,
          );
    notifyListeners();
  }

  /// Guarda el registro con la foto ya subida. Devuelve el error, si hubo.
  Future<String?> _saveEvidenceLog(String habitId, EvidenceCheck check) async {
    try {
      final log = await _repository.markDoneWithEvidence(
        habitId,
        _clock(),
        check.photoPath,
      );
      _remember(log, check.photo);
      _applyLog(habitId, log);
      return null;
    } catch (e) {
      return _messageFor(e);
    }
  }

  // ── Ver la foto de un hábito cumplido ────────────────────────────────────

  /// Fotos que ya están en el teléfono, por ruta, para no bajarlas otra vez.
  final Map<String, Uint8List> _photos = {};

  /// La foto con la que se marcó el hábito. Si se subió desde este teléfono
  /// en esta sesión, no se descarga.
  ///
  /// Lanza [HomeDataException] si no se pudo cargar.
  Future<Uint8List> evidencePhotoFor(String habitId) async {
    final path = _findLog(habitId)?.evidencePath;
    if (path == null) throw const HomeDataException('Este hábito no tiene foto');

    final saved = _photos[path];
    if (saved != null) return saved;

    try {
      final photo = await _repository.downloadEvidence(path);
      _photos[path] = photo;
      return photo;
    } catch (e) {
      debugPrint('No se pudo descargar la foto: ${e.runtimeType}');
      throw const HomeDataException(
        'No se pudo cargar la foto. Revisa tu conexión.',
      );
    }
  }

  void _remember(HabitLog log, Uint8List? photo) {
    final path = log.evidencePath;
    if (path != null && photo != null) _photos[path] = photo;
  }

  HabitLog? _findLog(String habitId) {
    for (final h in _habits) {
      if (h.habit.id == habitId) return h.log;
    }
    return null;
  }

  bool _isCurrent(String habitId, EvidenceCheck check) =>
      _checks[habitId]?.id == check.id;

  HomeHabit? _findHabit(String habitId) {
    for (final h in _habits) {
      if (h.habit.id == habitId) return h.habit;
    }
    return null;
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

  // ── Sincronización con HabitsProvider ───────────────────────────────────

  HabitsProvider? _habitsProvider;

  /// Inyecta el [HabitsProvider] y registra el callback de sincronización:
  /// cuando los hábitos cambian (crear/editar/borrar), el Home se recarga.
  // ignore: use_setters_to_change_properties
  void setHabitsProvider(HabitsProvider habits) {
    _habitsProvider = habits;
    // Cuando los hábitos cambian, recarga el Home.
    habits.onHabitChanged = load;
  }
}
