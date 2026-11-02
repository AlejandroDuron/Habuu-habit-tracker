// Los datos son fakes porque segun lo visto en clase, asi simulamos el comportamiento de la fuente de dtaos real.


import 'package:habuu/data/datasources/habit_data_source.dart';
import 'package:habuu/data/models/habit.dart';
import 'package:habuu/data/models/habit_log.dart';

class FakeHabitDataSource implements HabitDataSource {
  FakeHabitDataSource({
    List<Habit> initialHabits = const [],
    Map<String, LogStatus> logStatuses = const {},
  })  : _habits = [...initialHabits],
        _logStatuses = {...logStatuses};

  final List<Habit> _habits;
  final Map<String, LogStatus> _logStatuses;

  ///Sirve para probar qué hace la app cuando falla la conexión
  bool shouldFail = false;
  int _nextId = 1;

  /// Lo usamos para comprobar que el provider no llama a la fuente cuando la validación falla antes
  int createCalls = 0;

  void _failIfNeeded() {
    if (shouldFail) throw Exception('Error simulado de conexión');
  }

  @override
  Future<List<Habit>> getHabits() async {
    _failIfNeeded();
    return List.unmodifiable(_habits);
  }

  @override
  Future<Habit> createHabit(Habit habit) async {
    createCalls++;
    _failIfNeeded();
    final saved = habit.copyWith(id: 'fake-${_nextId++}');
    _habits.add(saved);
    return saved;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    _failIfNeeded();
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) throw HabitNotFoundException(habit.id);
    _habits[index] = habit;
    return habit;
  }

  @override
  Future<void> deleteHabit(String id) async {
    _failIfNeeded();
    final before = _habits.length;
    _habits.removeWhere((h) => h.id == id);
    if (_habits.length == before) throw HabitNotFoundException(id);
  }

  @override
  Future<Map<String, LogStatus>> getLogStatusesForDay(DateTime day) async {
    _failIfNeeded();
    return Map.unmodifiable(_logStatuses);
  }
}

///En cada prueba solo cambiamos lo que nos interesa, así no repetimos tantos parámetros cada vez
Habit buildHabit({
  String id = '',
  String name = 'Tomar agua',
  HabitType type = HabitType.frecuente,
  HabitCategory category = HabitCategory.salud,
  HabitRepeat? repeat = HabitRepeat.diariamente,
  Set<int> days = const {},
  int goalPerDay = 1,
  DateTime? createdAt,
}) {
  return Habit(
    id: id,
    name: name,
    type: type,
    category: category,
    iconIndex: 0,
    colorValue: 0xFFFFC654,
    reminderTime: null,
    goalPerDay: goalPerDay,
    // Un hábito fugaz no lleva repetición
    repeat: type == HabitType.fugaz ? null : repeat,
    days: days,
    remindersEnabled: false,
    createdAt: createdAt ?? DateTime(2026, 11, 2, 8),
  );
}