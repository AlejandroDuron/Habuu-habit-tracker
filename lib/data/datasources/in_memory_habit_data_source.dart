import '../models/habit.dart';
import 'habit_data_source.dart';
 
class InMemoryHabitDataSource implements HabitDataSource {
  // Hábito de prueba para visualizar las tarjetas en HabitsListScreen.
  // Quitar cuando se conecte el backend real.
  final List<Habit> _habits = [
    Habit(
      id: 'preview-1',
      name: 'Tomar Agua',
      type: HabitType.frecuente,
      category: HabitCategory.salud,
      iconIndex: 0,
      colorValue: 0xFF13533A,
      repeat: HabitRepeat.diariamente,
      goalPerDay: 8,
      reminderTime: HabitReminderTime.manana,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];
 
  @override
  Future<List<Habit>> getHabits() async {
    // Devolvemos una copia que no se puede modificar, para que nadie de
    // afuera cambie nuestra lista sin pasar por estos métodos.
    return List.unmodifiable(_habits);
  }
 
  @override
  Future<Habit> createHabit(Habit habit) async {
    // Generamos un id con la hora en microsegundos; así no hace falta
    // instalar otro paquete solo para esto
    final saved = habit.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
    );
    _habits.add(saved);
    return saved;
  }
 
  @override
  Future<Habit> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);

    //En vez de dejar que truene con un RangeError
    if (index == -1) {
      throw HabitNotFoundException(habit.id);
    }
 
    _habits[index] = habit;
    return habit;
  }
 
  @override
  Future<void> deleteHabit(String id) async {
    final lengthBefore = _habits.length;
    _habits.removeWhere((h) => h.id == id);
 
    // Si la lista quedó del mismo tamaño, no se borró nada
    if (_habits.length == lengthBefore) {
      throw HabitNotFoundException(id);
    }
  }
}