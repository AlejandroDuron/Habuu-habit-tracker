import '../../utils/dates.dart';
import '../models/habit_log.dart';
import '../models/home_habit.dart';
import 'home_data_source.dart';

/// Guarda todo en memoria, sin red. Sirve para probar el Home
/// sin depender de Supabase.
class FakeHomeDataSource implements HomeDataSource {
  FakeHomeDataSource({
    List<HomeHabit> habits = const [],
    List<HabitLog> logs = const [],
    this.signedIn = true,
  }) : _habits = [...habits],
       _logs = [...logs];

  final List<HomeHabit> _habits;
  final List<HabitLog> _logs;

  /// Si es false, se comporta como si nadie hubiera iniciado sesión.
  bool signedIn;

  @override
  Future<List<HomeHabit>> getActiveHabits() async {
    _checkSession();
    return List.unmodifiable(_habits);
  }

  @override
  Future<List<HabitLog>> getLogsOn(DateTime day) async {
    _checkSession();
    final date = dateOnly(day);
    return _logs.where((l) => l.logDate == date).toList();
  }

  @override
  Future<HabitLog> saveLog({
    required String habitId,
    required DateTime day,
    required LogStatus status,
    String? evidencePath,
  }) async {
    _checkSession();
    final date = dateOnly(day);
    final index = _logs.indexWhere(
      (l) => l.habitId == habitId && l.logDate == date,
    );

    final saved = HabitLog(
      // Si ya había registro ese día se conserva su id, como en la base.
      id: index == -1
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : _logs[index].id,
      habitId: habitId,
      logDate: date,
      status: status,
      evidencePath: evidencePath,
    );

    if (index == -1) {
      _logs.add(saved);
    } else {
      _logs[index] = saved;
    }
    return saved;
  }

  void _checkSession() {
    if (!signedIn) throw const NotSignedInException();
  }
}
