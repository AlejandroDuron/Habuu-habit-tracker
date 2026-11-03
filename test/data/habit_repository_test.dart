// Como el repository recibe el data source por constructor, en la app le
// pasamos el de Supabase y aquí el fake, sin cambiar ni una línea del repository

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/datasources/habit_data_source.dart';
import 'package:habuu/data/models/habit_log.dart';
import 'package:habuu/data/repositories/habit_repository.dart';

import '../fakes/fake_habit_data_source.dart';

void main() {
  // Se crean de nuevo antes de cada prueba para que ninguna prueba
  // dependa de lo que dejó la anterior
  late FakeHabitDataSource dataSource;
  late HabitRepository repository;

  setUp(() {
    dataSource = FakeHabitDataSource();
    repository = HabitRepository(dataSource);
  });

  test('getHabits devuelve del más nuevo al más viejo', () async {
    dataSource = FakeHabitDataSource(
      initialHabits: [
        buildHabit(id: '1', name: 'Viejo', createdAt: DateTime(2026, 10, 1)),
        buildHabit(id: '2', name: 'Nuevo', createdAt: DateTime(2026, 11, 1)),
        buildHabit(id: '3', name: 'Medio', createdAt: DateTime(2026, 10, 15)),
      ],
    );
    repository = HabitRepository(dataSource);

    final habits = await repository.getHabits();

    expect(habits.map((h) => h.name), ['Nuevo', 'Medio', 'Viejo']);
  });

  test('getHabits no truena aunque la fuente dé una lista fija', () async {
    dataSource = FakeHabitDataSource(initialHabits: [buildHabit(id: '1')]);
    repository = HabitRepository(dataSource);

    expect(await repository.getHabits(), hasLength(1));
  });

  test('createHabit devuelve el hábito con id asignado', () async {
    final saved = await repository.createHabit(buildHabit());

    expect(saved.id, isNotEmpty);
    expect(await repository.getHabits(), hasLength(1));
  });

  test('updateHabit reemplaza el hábito con el mismo id', () async {
    final saved = await repository.createHabit(buildHabit(name: 'Leer'));
    await repository.updateHabit(saved.copyWith(name: 'Leer 1 hora'));

    final habits = await repository.getHabits();
    expect(habits.single.name, 'Leer 1 hora');
  });

  test('updateHabit lanza HabitNotFoundException si no existe', () async {
    expect(
      () => repository.updateHabit(buildHabit(id: 'no-existe')),
      throwsA(isA<HabitNotFoundException>()),
    );
  });

  test('deleteHabit borra y avisa si el id no existe', () async {
    final saved = await repository.createHabit(buildHabit());
    await repository.deleteHabit(saved.id);

    expect(await repository.getHabits(), isEmpty);
    expect(
      () => repository.deleteHabit(saved.id),
      throwsA(isA<HabitNotFoundException>()),
    );
  });

  test('getLogStatusesForDay pasa los datos tal cual', () async {
    dataSource = FakeHabitDataSource(
      logStatuses: {'a': LogStatus.done, 'b': LogStatus.skipped},
    );
    repository = HabitRepository(dataSource);

    final statuses = await repository.getLogStatusesForDay(DateTime.now());

    expect(statuses['a'], LogStatus.done);
    expect(statuses['b'], LogStatus.skipped);
  });

  test('si la fuente falla, el error sube hasta quien llamó', () async {
    dataSource.shouldFail = true;

    expect(() => repository.getHabits(), throwsException);
  });
}
