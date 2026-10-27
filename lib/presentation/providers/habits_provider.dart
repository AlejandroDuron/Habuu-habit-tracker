import 'package:flutter/foundation.dart';
 
import '../../data/datasources/habit_data_source.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';
 
class HabitsProvider extends ChangeNotifier {
  HabitsProvider(this._repository);
 
  final HabitRepository _repository;
 
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<Habit> get frequentHabits =>
      _habits.where((h) => h.type == HabitType.frecuente).toList();
 
  List<Habit> get fleetingHabits =>
      _habits.where((h) => h.type == HabitType.fugaz).toList();
 
  /// Busca un hábito por id. Devuelve null si no lo encuentra, en vez de
  /// lanzar un error, porque la pantalla de editar puede abrirse con un
  /// hábito que alguien ya borró
  Habit? findById(String id) {
    for (final habit in _habits) {
      if (habit.id == id) return habit;
    }
    return null;
  }
 
  /// Carga los hábitos desde el repository. Se llama una vez al iniciar la app
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
 
  /// Guarda un hábito nuevo. Devuelve true si salió bien, para que la
  /// pantalla sepa si mostrar:
  Future<bool> addHabit(Habit habit) async {
    try {
      final saved = await _repository.createHabit(habit);
      // Lo ponemos al inicio para respetar el orden del mas reciente
      _habits = [saved, ..._habits];
      _errorMessage = null;
      notifyListeners();
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
 
  /// Cambia el orden de un hábito dentro de su lista cuando el usuario lo arrastra.
  /// oldIndex y newIndex son posiciones dentro de esa lista filtrada, no
  /// dentro de _habits; por eso los hábitos del otro tipo se quedan
  /// donde estaban.
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
 
    // cada vez que aparece un hábito
    // de este tipo, ponemos el siguiente de la lista ya ordenada
    var next = 0;
    _habits = [
      for (final h in _habits) h.type == type ? sameType[next++] : h,
    ];
    notifyListeners();
  }
 
  /// Borra un hábito. Da true si salió bien
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