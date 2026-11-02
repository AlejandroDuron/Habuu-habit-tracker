import 'package:flutter/foundation.dart';

import '../../data/datasources/habit_data_source.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';
import 'trophies_provider.dart';

// ── Enums de filtro ────────────────────────────────────────────────────────

/// Período de tiempo para filtrar la lista de hábitos.
enum HabitPeriodFilter { today, week, all }

/// Filtro combinado de tipo y categoría.
enum HabitChipFilter {
  all,
  frequent,
  fleeting,
  health,
  home,
  university,
}

// ── Provider ───────────────────────────────────────────────────────────────

class HabitsProvider extends ChangeNotifier {
  HabitsProvider(this._repository, {TrophiesProvider? trophies})
      : _trophies = trophies;

  final HabitRepository _repository;

  /// Permite inyectar el provider de trofeos para disparar evaluaciones.
  TrophiesProvider? _trophies;

  // ignore: use_setters_to_change_properties
  void setTrophiesProvider(TrophiesProvider trophies) {
    _trophies = trophies;
  }

  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filtros activos — la pantalla los cambia; el provider recalcula la vista.
  HabitPeriodFilter _periodFilter = HabitPeriodFilter.all;
  HabitChipFilter _chipFilter = HabitChipFilter.all;

  // ── Getters básicos ──────────────────────────────────────────────────────

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HabitPeriodFilter get periodFilter => _periodFilter;
  HabitChipFilter get chipFilter => _chipFilter;

  List<Habit> get frequentHabits =>
      _habits.where((h) => h.type == HabitType.frecuente).toList();

  List<Habit> get fleetingHabits =>
      _habits.where((h) => h.type == HabitType.fugaz).toList();

  // ── Getter de lista filtrada ─────────────────────────────────────────────

  /// Lista de hábitos aplicando [periodFilter] y [chipFilter].
  /// Se recalcula solo cuando cambia _habits o algún filtro.
  List<Habit> get filteredHabits {
    final byPeriod = _applyPeriodFilter(_habits);
    return _applyChipFilter(byPeriod);
  }

  // ── Cambio de filtros ────────────────────────────────────────────────────

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

  // ── Lógica de filtrado ───────────────────────────────────────────────────

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
          final weekStart =
              today.subtract(Duration(days: today.weekday - 1));
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
      HabitChipFilter.health =>
        all.where((h) => h.category == HabitCategory.salud).toList(),
      HabitChipFilter.home =>
        all.where((h) => h.category == HabitCategory.hogar).toList(),
      HabitChipFilter.university =>
        all.where((h) => h.category == HabitCategory.universidad).toList(),
      HabitChipFilter.all => all,
    };
  }

  /// Si un hábito frecuente aplica para [today] según su repetición.
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

  /// Si un hábito frecuente tiene al menos una ocurrencia en la semana
  /// que comienza en [weekStart] (lunes).
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

  // ── Operaciones sobre hábitos ────────────────────────────────────────────

  /// Busca un hábito por id. Devuelve null si no lo encuentra.
  Habit? findById(String id) {
    for (final habit in _habits) {
      if (habit.id == id) return habit;
    }
    return null;
  }

  /// Carga los hábitos desde el repository. Se llama una vez al iniciar la app.
  Future<void> loadHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _habits = await _repository.getHabits();
    } catch (e) {
      _errorMessage = 'No se pudieron cargar tus hábitos';
      debugPrint('Error al cargar hábitos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guarda un hábito nuevo. Devuelve true si salió bien.
  Future<bool> addHabit(Habit habit) async {
    // Validación en cliente: nombre duplicado (case-insensitive).
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
      // Al inicio para respetar el orden del más reciente.
      _habits = [saved, ..._habits];
      _errorMessage = null;
      notifyListeners();

      // Trofeo por crear un nuevo hábito (se otorga solo la primera vez).
      _trophies?.checkNewHabit().catchError(
        (e) => debugPrint('Error al evaluar new_habits: $e'),
      );

      // Trofeo de un mes con Habuu: la fecha más antigua es la del hábito más viejo.
      final oldest = _habits.reduce(
        (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
      );
      _trophies?.checkOneMonth(firstHabitDate: oldest.createdAt).catchError(
        (e) => debugPrint('Error al evaluar one_month: $e'),
      );

      return true;
    } catch (e) {
      _errorMessage = 'No se pudo crear el hábito';
      debugPrint('Error al crear hábito: $e');
      notifyListeners();
      return false;
    }
  }

  /// Reemplaza un hábito editado. Devuelve true si salió bien.
  Future<bool> updateHabit(Habit habit) async {
    // Validación en cliente: nombre duplicado con otro hábito distinto.
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
      _habits = [
        for (final h in _habits) h.id == saved.id ? saved : h,
      ];
      _errorMessage = null;
      notifyListeners();
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

  /// Cambia el orden de un hábito dentro de su tipo.
  ///
  /// [oldIndex] y [newIndex] son posiciones dentro de la lista filtrada
  /// por tipo, no dentro de [_habits]; los hábitos del otro tipo no se mueven.
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
    _habits = [
      for (final h in _habits) h.type == type ? sameType[next++] : h,
    ];
    notifyListeners();
  }

  /// Borra un hábito. Devuelve true si salió bien.
  Future<bool> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      _habits = _habits.where((h) => h.id != id).toList();
      _errorMessage = null;
      notifyListeners();
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
}
