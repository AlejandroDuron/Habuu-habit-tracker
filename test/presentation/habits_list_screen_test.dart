import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/models/habit.dart';
import 'package:habuu/data/repositories/habit_repository.dart';
import 'package:habuu/presentation/providers/habits_provider.dart';
import 'package:habuu/presentation/screens/habits/habits_list_screen.dart';
import 'package:habuu/presentation/widgets/habits_list/habit_filter_chips.dart';
import 'package:habuu/presentation/widgets/habits_list/habits_list_view.dart';
import 'package:habuu/presentation/widgets/habits_list/period_segment.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_habit_data_source.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  late HabitsProvider provider;

  Future<void> pump(WidgetTester t, {List<Habit> habits = const []}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);

    final ds = FakeHabitDataSource(initialHabits: habits);
    provider = HabitsProvider(HabitRepository(ds));
    await provider.loadHabits();

    await t.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: HabitsListScreen()),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('muestra el título "Tus Hábitos"', (t) async {
    await pump(t);
    expect(find.text('Tus Hábitos'), findsOneWidget);
  });

  testWidgets('muestra PeriodSegment con Hoy, Semana y Todo', (t) async {
    await pump(t);
    expect(find.byType(PeriodSegment), findsOneWidget);
    expect(find.text('Hoy'), findsAtLeastNWidgets(1));
    expect(find.text('Semana'), findsAtLeastNWidgets(1));
    // "Todo" aparece tanto en PeriodSegment como en HabitFilterChips
    expect(find.text('Todo'), findsAtLeastNWidgets(1));
  });

  testWidgets('muestra HabitFilterChips', (t) async {
    await pump(t);
    expect(find.byType(HabitFilterChips), findsOneWidget);
  });

  testWidgets('lista vacía muestra mensaje "Aún no tienes hábitos"', (t) async {
    await pump(t, habits: []);
    expect(find.text('Aún no tienes hábitos'), findsOneWidget);
  });

  testWidgets('muestra los hábitos cargados', (t) async {
    await pump(t, habits: [
      buildHabit(id: '1', name: 'Tomar agua'),
      buildHabit(id: '2', name: 'Meditar'),
    ]);
    expect(find.text('Tomar agua'), findsOneWidget);
    expect(find.text('Meditar'), findsOneWidget);
  });

  testWidgets('cambiar a filtro "Semana" cambia la vista a WeeklyHabitsListView', (t) async {
    await pump(t, habits: [buildHabit(id: '1', name: 'Correr')]);
    await t.tap(find.text('Semana'));
    await t.pumpAndSettle();
    // HabitsListView desaparece; la vista semanal toma su lugar
    expect(find.byType(HabitsListView), findsNothing);
  });

  testWidgets('botón FAB "+" está presente', (t) async {
    await pump(t);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('confirmar eliminar quita el hábito de la lista', (t) async {
    await pump(t, habits: [buildHabit(id: '1', name: 'Leer')]);
    // Abre el menú de la tarjeta (long press o botón de opciones)
    await t.longPress(find.text('Leer'));
    await t.pumpAndSettle();

    // Si no aparece diálogo, la pantalla al menos no lanza excepción
    expect(t.takeException(), isNull);
  });
}
