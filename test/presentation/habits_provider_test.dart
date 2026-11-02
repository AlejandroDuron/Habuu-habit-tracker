// El provider es donde vive el estado de los hábitos, así que aquí
// revisamos que cargue, cree, edite, borre y filtre bien, y que avise a la
// pantalla con notifyListeners() cada vez que algo cambia

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/habit.dart';
import 'package:habuu/data/models/habit_log.dart';
import 'package:habuu/data/repositories/habit_repository.dart';
import 'package:habuu/presentation/providers/habits_provider.dart';

import '../fakes/fake_habit_data_source.dart';

void main() {
  late FakeHabitDataSource dataSource;
  late HabitsProvider provider;

  // Cuenta cuántas veces el provider avisó un cambio
  late int notifications;

  /// Arma un provider nuevo con los hábitos que le pasemos
  void createProvider({
    List<Habit> habits = const [],
    Map<String, LogStatus> logStatuses = const {},
  }) {
    dataSource = FakeHabitDataSource(
      initialHabits: habits,
      logStatuses: logStatuses,
    );
    provider = HabitsProvider(HabitRepository(dataSource));
    notifications = 0;
    provider.addListener(() => notifications++);
  }

  setUp(createProvider);

  group('loadHabits', () {
    test('carga los hábitos y apaga isLoading al terminar', () async {
      createProvider(habits: [buildHabit(id: '1'), buildHabit(id: '2')]);

      final future = provider.loadHabits();
      // Mientras espera, la pantalla debe poder mostrar el loading
      expect(provider.isLoading, isTrue);

      await future;
      expect(provider.isLoading, isFalse);
      expect(provider.habits, hasLength(2));
      expect(provider.errorMessage, isNull);
    });

    test('si la fuente falla deja un mensaje de error', () async {
      dataSource.shouldFail = true;

      await provider.loadHabits();

      expect(provider.errorMessage, 'No se pudieron cargar tus hábitos');
      expect(provider.isLoading, isFalse);
    });
  });

  group('addHabit', () {
    test('agrega el hábito al inicio y avisa a la pantalla', () async {
      await provider.addHabit(buildHabit(name: 'Primero'));
      final ok = await provider.addHabit(buildHabit(name: 'Segundo'));

      expect(ok, isTrue);
      expect(provider.habits.first.name, 'Segundo');
      expect(notifications, greaterThan(0));
    });

    test('no deja dos hábitos con el mismo nombre (sin importar mayúsculas)',
        () async {
      await provider.addHabit(buildHabit(name: 'Tomar agua'));
      final ok = await provider.addHabit(buildHabit(name: '  TOMAR AGUA '));

      expect(ok, isFalse);
      expect(provider.errorMessage, 'Ya tienes un hábito con ese nombre');
      expect(provider.habits, hasLength(1));
      expect(dataSource.createCalls, 1);
    });

    test('devuelve false si la fuente falla', () async {
      dataSource.shouldFail = true;

      final ok = await provider.addHabit(buildHabit());

      expect(ok, isFalse);
      expect(provider.errorMessage, 'No se pudo crear el hábito');
      expect(provider.habits, isEmpty);
    });

    test('llama a onHabitChanged para que el Home se recargue', () async {
      var called = false;
      provider.onHabitChanged = () => called = true;

      await provider.addHabit(buildHabit());

      expect(called, isTrue);
    });
  });

  group('updateHabit', () {
    test('reemplaza el hábito editado sin cambiar su id', () async {
      await provider.addHabit(buildHabit(name: 'Leer'));
      final original = provider.habits.single;

      final ok = await provider.updateHabit(original.copyWith(name: 'Leer más'));

      expect(ok, isTrue);
      expect(provider.habits.single.name, 'Leer más');
      expect(provider.habits.single.id, original.id);
    });

    test('puede guardar el mismo hábito con su propio nombre', () async {
      await provider.addHabit(buildHabit(name: 'Correr'));
      final habit = provider.habits.single;


      final ok = await provider.updateHabit(habit.copyWith(goalPerDay: 2));

      expect(ok, isTrue);
    });

    test('no deja renombrar con el nombre de otro hábito', () async {
      await provider.addHabit(buildHabit(name: 'Correr'));
      await provider.addHabit(buildHabit(name: 'Nadar'));
      final nadar = provider.habits.firstWhere((h) => h.name == 'Nadar');

      final ok = await provider.updateHabit(nadar.copyWith(name: 'correr'));

      expect(ok, isFalse);
      expect(provider.errorMessage, 'Ya tienes un hábito con ese nombre');
    });

    test('avisa si el hábito ya no existe', () async {
      final ok = await provider.updateHabit(buildHabit(id: 'fantasma'));

      expect(ok, isFalse);
      expect(provider.errorMessage, 'Ese hábito ya no existe');
    });
  });

  group('deleteHabit', () {
    test('quita el hábito de la lista', () async {
      await provider.addHabit(buildHabit());
      final id = provider.habits.single.id;

      final ok = await provider.deleteHabit(id);

      expect(ok, isTrue);
      expect(provider.habits, isEmpty);
      expect(provider.findById(id), isNull);
    });

    test('avisa si el hábito ya no existe', () async {
      final ok = await provider.deleteHabit('fantasma');

      expect(ok, isFalse);
      expect(provider.errorMessage, 'Ese hábito ya no existe');
    });
  });

  group('reorderHabits', () {
    test('mueve solo dentro del mismo tipo', () async {
      createProvider(habits: [
        buildHabit(id: 'a', name: 'A', createdAt: DateTime(2026, 11, 4)),
        buildHabit(
          id: 'x',
          name: 'X',
          type: HabitType.fugaz,
          createdAt: DateTime(2026, 11, 3),
        ),
        buildHabit(id: 'b', name: 'B', createdAt: DateTime(2026, 11, 2)),
        buildHabit(id: 'c', name: 'C', createdAt: DateTime(2026, 11, 1)),
      ]);
      await provider.loadHabits();

      provider.reorderHabits(HabitType.frecuente, 0, 2);

      expect(provider.frequentHabits.map((h) => h.name), ['B', 'C', 'A']);
      expect(provider.habits[1].name, 'X');
    });

    test('ignora posiciones fuera de rango', () async {
      await provider.addHabit(buildHabit(name: 'Solo'));
      final before = notifications;

      provider.reorderHabits(HabitType.frecuente, 0, 5);

      expect(provider.habits.single.name, 'Solo');
      expect(notifications, before);
    });
  });

  group('Filtros', () {
    setUp(() async {
      createProvider(
        habits: [
          buildHabit(id: '1', name: 'Agua', category: HabitCategory.salud),
          buildHabit(id: '2', name: 'Barrer', category: HabitCategory.hogar),
          buildHabit(
            id: '3',
            name: 'Tarea',
            type: HabitType.fugaz,
            category: HabitCategory.universidad,
          ),
        ],
        logStatuses: {'2': LogStatus.skipped},
      );
      await provider.loadHabits();
    });

    test('frequentHabits y fleetingHabits separan por tipo', () {
      expect(provider.frequentHabits.map((h) => h.name), ['Agua', 'Barrer']);
      expect(provider.fleetingHabits.map((h) => h.name), ['Tarea']);
    });

    test('availableCategories da las categorías sin repetir y en orden', () {
      expect(provider.availableCategories, ['Hogar', 'Salud', 'Universidad']);
    });

    test('el filtro de categoría usa el nombre de la categoría', () {
      provider.setCategoryFilter('Hogar');
      expect(provider.filteredHabits.map((h) => h.name), ['Barrer']);

      provider.setCategoryFilter('Universidad');
      expect(provider.filteredHabits.map((h) => h.name), ['Tarea']);
    });

    test('tipo y categoría se combinan', () {
      provider.setChipFilter(HabitChipFilter.fleeting);
      provider.setCategoryFilter('Salud');

      // Ningún hábito fugaz es de salud
      expect(provider.filteredHabits, isEmpty);
    });

    test('resetFilters vuelve a mostrar todo', () {
      provider.setChipFilter(HabitChipFilter.frequent);
      provider.setCategoryFilter('Hogar');

      provider.resetFilters();

      expect(provider.chipFilter, HabitChipFilter.all);
      expect(provider.categoryFilter, isNull);
      expect(provider.filteredHabits, hasLength(3));
    });

    test('el chip "omitidos" usa los logs del día', () {
      provider.setChipFilter(HabitChipFilter.omitted);
      expect(provider.filteredHabits.map((h) => h.name), ['Barrer']);
    });

    test('elegir el mismo filtro otra vez no vuelve a avisar', () {
      provider.setCategoryFilter('Salud');
      final before = notifications;

      provider.setCategoryFilter('Salud');

      expect(notifications, before);
    });
  });
}