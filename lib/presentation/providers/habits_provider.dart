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
 
  // Getters públicos. La lista se entrega sin poder modificarse, para que
  // todos los cambios pasen por los métodos de aquí y siempre se avise
  // con notifyListeners().
  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
 
  // Valores derivados: se calculan de _habits cada vez que se piden, así
  // nunca quedan desincronizados (lo de "derivado frente a paralelo").
  List<Habit> get frequentHabits =>
      _habits.where((h) => h.type == HabitType.frecuente).toList();
 
  List<Habit> get fleetingHabits =>
      _habits.where((h) => h.type == HabitType.fugaz).toList();
 
  /// Busca un hábito por id. Devuelve null si no lo encuentra, en vez de
  /// lanzar un error, porque la pantalla de editar puede abrirse con un
  /// hábito que alguien ya borró.
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
 
  /// Guarda un hábito nuevo. Devuelve true si salió bien, para que la
  /// pantalla sepa si mostrar "Hábito creado correctamente".
  Future<bool> addHabit(Habit habit) async {
    try {
      final saved = await _repository.createHabit(habit);
      // Lo ponemos al inicio para respetar el orden "más nuevo primero".
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
      // Error con nombre propio: sabemos exactamente qué pasó.
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