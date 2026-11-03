import 'package:flutter/foundation.dart';

import '../../data/datasources/habit_data_source.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_log.dart';
import '../../data/repositories/habit_repository.dart';
import '../../services/notification_service.dart';
import '../../utils/dates.dart';
import 'trophies_provider.dart';

//Enums para filtrar la lista de hábitos

/// Período de tiempo para filtrar la lista de hábitos
enum HabitPeriodFilter { today, week, all }

/// Filtro combinado de tipo y estado
enum HabitChipFilter { all, frequent, fleeting, omitted }

//provider que mantiene la lista de hábitos y sus logs del día, y los filtros activos

class HabitsProvider extends ChangeNotifier {
  HabitsProvider(
    this._repository, {
    TrophiesProvider? trophies,
    HabitReminderScheduler? reminders,
  }) : _trophies = trophies,
       _reminders = reminders;

  final HabitRepository _repository;

  /// Programa las notificaciones de cada hábito
  final HabitReminderScheduler? _reminders;

  /// Permite inyectar el provider de trofeos para disparar evaluaciones
  TrophiesProvider? _trophies;


  void setTrophiesProvider(TrophiesProvider trophies) {
    _trophies = trophies;
  }

  /// Callback que se dispara para después de crear, editar o borrar un hábito

  VoidCallback? onHabitChanged;

  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;


  Map<String, LogStatus> _logStatuses = {};

  Map<String, Map<DateTime, LogStatus>> _weekStatuses = {};

 
  HabitPeriodFilter _periodFilter = HabitPeriodFilter.all;
  HabitChipFilter _chipFilter = HabitChipFilter.all;


  String? _categoryFilter;

  // Getters públicos para que la pantalla pueda leer el estado del provider

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  Map<String, LogStatus> get logStatuses => Map.unmodifiable(_logStatuses);

  Map<DateTime, LogStatus> weekStatusesFor(String habitId) =>
      Map.unmodifiable(_weekStatuses[habitId] ?? const {});

  HabitPeriodFilter get periodFilter => _periodFilter;
  HabitChipFilter get chipFilter => _chipFilter;

  /// Categoría activa como string
  String? get categoryFilter => _categoryFilter;

  /// Lista de categorías únicas presentes en los hábitos cargados

  List<String> get availableCategories {
    final seen = <String>{};
    final result = <String>[];
    for (final h in _habits) {
      if (seen.add(h.categoryLabel)) result.add(h.categoryLabel);
    }
    result.sort();
    return result;
  }

  List<Habit> get frequentHabits =>
      _habits.where((h) => h.type == HabitType.frecuente).toList();

  List<Habit> get fleetingHabits =>
      _habits.where((h) => h.type == HabitType.fugaz).toList();

  // Getter que devuelve la lista de hábitos filtrada por los filtros activos


  List<Habit> get filteredHabits {
    final byPeriod = _applyPeriodFilter(_habits);
    final byChip = _applyChipFilter(byPeriod);
    if (_categoryFilter == null) return byChip;
    return byChip.where((h) => h.categoryLabel == _categoryFilter).toList();
  }

  void setPeriodFilter(HabitPeriodFilter filter) {
    if (_periodFilter == filter) return;
    _periodFilter = filter;
    notifyListeners();
  }

  void setChipFilter(HabitChipFilter filter) {
    if (_chipFilter == filter) return;
    _chipFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    notifyListeners();
  }

  void resetFilters() {
    if (_chipFilter == HabitChipFilter.all && _categoryFilter == null) return;
    _chipFilter = HabitChipFilter.all;
    _categoryFilter = null;
    notifyListeners();
  }

  //Filtrado

  List<Habit> _applyPeriodFilter(List<Habit> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return switch (_periodFilter) {
      HabitPeriodFilter.today => all.where((h) {
        final created = DateTime(
          h.createdAt.year,
          h.createdAt.month,
          h.createdAt.day,
        );
        if (h.type == HabitType.fugaz) return created == today;
        return _isScheduledToday(h, today);
      }).toList(),

      HabitPeriodFilter.week => all.where((h) {
        final weekStart = weekStartOf(today);
        final weekEnd = weekStart.add(const Duration(days: 6));
        final created = DateTime(
          h.createdAt.year,
          h.createdAt.month,
          h.createdAt.day,
        );
        if (!created.isBefore(weekStart) && !created.isAfter(weekEnd)) {
          return true;
        }
        if (h.type == HabitType.fugaz) return false;
        return _hasOccurrenceInWeek(h, weekStart);
      }).toList(),

      HabitPeriodFilter.all => all,
    };
  }

  List<Habit> _applyChipFilter(List<Habit> all) {
    return switch (_chipFilter) {
      HabitChipFilter.frequent =>
        all.where((h) => h.type == HabitType.frecuente).toList(),
      HabitChipFilter.fleeting =>
        all.where((h) => h.type == HabitType.fugaz).toList(),
      HabitChipFilter.omitted =>
        all.where((h) => _logStatuses[h.id] == LogStatus.skipped).toList(),
      HabitChipFilter.all => all,
    };
  }


  static bool _isScheduledToday(Habit habit, DateTime today) {
    if (habit.type != HabitType.frecuente || habit.repeat == null) {
      return false;
    }
    return switch (habit.repeat!) {
      HabitRepeat.diariamente => true,
      HabitRepeat.semanalmente => habit.days.contains(today.weekday),
      HabitRepeat.mensualmente => habit.days.contains(today.day),
    };
  }


  static bool _hasOccurrenceInWeek(Habit habit, DateTime weekStart) {
    if (habit.repeat == null) return false;
    return switch (habit.repeat!) {
      HabitRepeat.diariamente => true,
      HabitRepeat.semanalmente => habit.days.isNotEmpty,
      HabitRepeat.mensualmente => habit.days.any((day) {
        for (var i = 0; i < 7; i++) {
          if (weekStart.add(Duration(days: i)).day == day) return true;
        }
        return false;
      }),
    };
  }

  //Operaciones CRUD y de recarga de logs

  /// Busca un hábito por id. Devuelve null si no lo encuentra
  Habit? findById(String id) {
    for (final habit in _habits) {
      if (habit.id == id) return habit;
    }
    return null;
  }

  /// Carga los hábitos y sus logs del día desde el repository
  Future<void> loadHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Carga hábitos y logs del día en paralelo
      final now = DateTime.now();
      final results = await Future.wait([
        _repository.getHabits(),
        _repository.getLogStatusesForDay(now),
        _repository.getWeekLogStatuses(now),
      ]);
      _habits = results[0] as List<Habit>;
      _logStatuses = results[1] as Map<String, LogStatus>;
      _weekStatuses = results[2] as Map<String, Map<DateTime, LogStatus>>;

      // Reprogramamos los avisos de todos los hábitos al abrir la app.
      // Así, si se cambió algo desde otro celular, los avisos quedan al día
      for (final habit in _habits) {
        _syncReminder(habit);
      }
    } catch (e) {
      _errorMessage = 'No se pudieron cargar tus hábitos';
      debugPrint('Error al cargar hábitos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recarga solo los logs del día
  Future<void> reloadLogStatuses() async {
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        _repository.getLogStatusesForDay(now),
        _repository.getWeekLogStatuses(now),
      ]);
      _logStatuses = results[0] as Map<String, LogStatus>;
      _weekStatuses = results[1] as Map<String, Map<DateTime, LogStatus>>;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al recargar logs: $e');
    }
  }

  /// Guarda un hábito nuevo. Devuelve true si salió bien
  Future<bool> addHabit(Habit habit) async {
   
    final nameLower = habit.name.trim().toLowerCase();
    final duplicate = _habits.any(
      (h) => h.name.trim().toLowerCase() == nameLower,
    );
    if (duplicate) {
      _errorMessage = 'Ya tienes un hábito con ese nombre';
      notifyListeners();
      return false;
    }

    try {
      final saved = await _repository.createHabit(habit);
      // Al inicio para respetar el orden del más reciente
      _habits = [saved, ..._habits];
      _errorMessage = null;
      notifyListeners();

      // Programamos su recordatorio, si ya tiene id asignado
      _syncReminder(saved);

      _trophies?.checkNewHabit().catchError(
        (e) => debugPrint('Error al evaluar new_habits: $e'),
      );


      final oldest = _habits.reduce(
        (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
      );
      _trophies
          ?.checkOneMonth(firstHabitDate: oldest.createdAt)
          .catchError((e) => debugPrint('Error al evaluar one_month: $e'));

      // Notifica al Home para que recargue los hábitos del día
      onHabitChanged?.call();

      return true;
    } catch (e) {
      _errorMessage = 'No se pudo crear el hábito';
      debugPrint('Error al crear hábito: $e');
      notifyListeners();
      return false;
    }
  }

  /// Reemplaza un hábito editado. Devuelve true si salió bien
  Future<bool> updateHabit(Habit habit) async {
 
    final nameLower = habit.name.trim().toLowerCase();
    final duplicate = _habits.any(
      (h) => h.id != habit.id && h.name.trim().toLowerCase() == nameLower,
    );
    if (duplicate) {
      _errorMessage = 'Ya tienes un hábito con ese nombre';
      notifyListeners();
      return false;
    }

    try {
      final saved = await _repository.updateHabit(habit);
      _habits = [for (final h in _habits) h.id == saved.id ? saved : h];
      _errorMessage = null;
      notifyListeners();
      // Si cambió la hora o los días, reprogramamos el aviso
      _syncReminder(saved);
      // Notifica al Home para que recargue los hábitos del día
      onHabitChanged?.call();
      return true;
    } on HabitNotFoundException {
      _errorMessage = 'Ese hábito ya no existe';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'No se pudieron guardar los cambios';
      debugPrint('Error al actualizar hábito: $e');
      notifyListeners();
      return false;
    }
  }
  /// Cambia el orden de los hábitos del mismo tipo. Se usa en la pantalla de lista
  void reorderHabits(HabitType type, int oldIndex, int newIndex) {
    final sameType = _habits.where((h) => h.type == type).toList();
    if (oldIndex == newIndex ||
        oldIndex < 0 ||
        oldIndex >= sameType.length ||
        newIndex < 0 ||
        newIndex >= sameType.length) {
      return;
    }

    final moved = sameType.removeAt(oldIndex);
    sameType.insert(newIndex, moved);

    var next = 0;
    _habits = [for (final h in _habits) h.type == type ? sameType[next++] : h];
    notifyListeners();
  }

  /// Borra un hábito. Devuelve true si salió bien
  Future<bool> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      _habits = _habits.where((h) => h.id != id).toList();
      _errorMessage = null;
      notifyListeners();
      // Un hábito borrado ya no debe seguir avisando
      _reminders
          ?.cancelFor(id)
          .catchError((e) => debugPrint('Error al cancelar recordatorio: $e'));
      // Notifica al Home para que recargue los hábitos del día
      onHabitChanged?.call();
      return true;
    } on HabitNotFoundException {
      _errorMessage = 'Ese hábito ya no existe';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'No se pudo borrar el hábito';
      debugPrint('Error al borrar hábito: $e');
      notifyListeners();
      return false;
    }
  }

  // ── Recordatorios ────────────────────────────────────────────────────────

  /// Programa los avisos de habit sin esperar la respuesta, si falla,
  /// solo lo anotamos en consola y el hábito se guarda igual
  void _syncReminder(Habit habit) {
    _reminders
        ?.scheduleFor(habit)
        .catchError((e) => debugPrint('Error al programar recordatorio: $e'));
  }

  /// Al cerrar sesión, los avisos de esta cuenta no deben seguir sonando
  /// en el celular
  Future<void> cancelAllReminders() async {
    try {
      await _reminders?.cancelAll();
    } catch (e) {
      debugPrint('Error al cancelar los recordatorios: $e');
    }
  }
}