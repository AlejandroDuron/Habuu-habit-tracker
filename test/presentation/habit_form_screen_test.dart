// Test de widget del formulario nuevo o editar hábito.
// La pantalla usa el provider con fuente fake, así no se toca Supabase.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/models/habit.dart';
import 'package:habuu/data/repositories/habit_repository.dart';
import 'package:habuu/presentation/providers/habits_provider.dart';
import 'package:habuu/presentation/screens/habits/habit_form_screen.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_habit_data_source.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  late HabitsProvider provider;

  setUp(() {
    provider = HabitsProvider(HabitRepository(FakeHabitDataSource()));
  });

  /// Monta el formulario dentro del provider.
  Future<void> openForm(WidgetTester tester, {Habit? habit}) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(home: HabitFormScreen(habit: habit)),
      ),
    );
  }

  /// Hace scroll hasta un widget y lo toca.
  Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
    FocusManager.instance.primaryFocus?.unfocus();
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .clearSnackBars();
    await tester.pumpAndSettle();
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder nameField() => find.byType(TextFormField).first;

  // El campo de meta es el último TextFormField del formulario.
  Finder goalField() => find.byType(TextFormField).last;

  // ── Estructura ─────────────────────────────────────────────────────────────

  testWidgets('muestra "Nuevo Hábito" con el toggle de tipo', (tester) async {
    await openForm(tester);

    expect(find.text('Nuevo Hábito'), findsOneWidget);
    expect(find.text('Habito Frecuente'), findsOneWidget);
    expect(find.text('Habito fugaz'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // ── Validación de nombre ───────────────────────────────────────────────────

  testWidgets('no guarda si el nombre está vacío', (tester) async {
    await openForm(tester);
    await scrollAndTap(tester, find.text('Guardar'));
    expect(find.text('Escribe el nombre del hábito'), findsOneWidget);
    expect(provider.habits, isEmpty);
  });

  testWidgets('valida largo y caracteres del nombre', (tester) async {
    await openForm(tester);

    await tester.enterText(nameField(), 'ab');
    await tester.pump();
    expect(find.text('Escribe al menos 3 caracteres'), findsOneWidget);

    await tester.enterText(nameField(), '1234');
    await tester.pump();
    expect(find.text('El nombre debe incluir al menos una letra'), findsOneWidget);

    await tester.enterText(nameField(), 'Agua @@');
    await tester.pump();
    expect(find.text('Usa solo letras, números y signos básicos'), findsOneWidget);
  });

  // ── Validación de meta (ahora texto libre) ─────────────────────────────────

  testWidgets('no guarda si la meta está vacía', (tester) async {
    await openForm(tester);
    await tester.enterText(nameField(), 'Tomar agua');
    // Dejamos la meta vacía y guardamos sin recordatorios
    await scrollAndTap(tester, find.text('Activar Recordatorios'));
    await scrollAndTap(tester, find.text('Guardar'));

    expect(find.text('Escribe la meta diaria'), findsOneWidget);
    expect(provider.habits, isEmpty);
  });

  testWidgets('meta con un solo carácter muestra error de longitud', (tester) async {
    await openForm(tester);
    await tester.enterText(goalField(), 'x');
    await tester.pump();
    expect(find.text('Escribe al menos 2 caracteres'), findsOneWidget);
  });

  testWidgets('meta puede ser texto libre (ej. "30 minutos")', (tester) async {
    await openForm(tester);
    await tester.enterText(nameField(), 'Correr');
    await tester.enterText(goalField(), '30 minutos');
    await tester.pump();
    // No debe mostrar error
    expect(find.text('Escribe al menos 2 caracteres'), findsNothing);
    expect(find.text('Escribe la meta diaria'), findsNothing);
  });

  // ── Recordatorios ──────────────────────────────────────────────────────────

  testWidgets('con recordatorios activos pide la hora', (tester) async {
    await openForm(tester);
    await tester.enterText(nameField(), 'Tomar agua');
    await tester.enterText(goalField(), '1 vaso');

    await scrollAndTap(tester, find.text('Guardar'));

    expect(find.text('Elige la hora del recordatorio'), findsOneWidget);
    expect(provider.habits, isEmpty);
  });

  // ── Repetición semanal ─────────────────────────────────────────────────────

  testWidgets('semanal sin días no se guarda', (tester) async {
    await openForm(tester);
    await tester.enterText(nameField(), 'Correr');
    await tester.enterText(goalField(), '5 km');
    await scrollAndTap(tester, find.text('Activar Recordatorios'));
    await scrollAndTap(tester, find.text('Semanalmente'));

    await scrollAndTap(tester, find.text('Guardar'));
    expect(find.text('Elige al menos un día de la semana'), findsOneWidget);

    await scrollAndTap(tester, find.bySemanticsLabel('Lunes'));
    await scrollAndTap(tester, find.text('Guardar'));

    expect(provider.habits.single.repeat, HabitRepeat.semanalmente);
    expect(provider.habits.single.days, {DateTime.monday});
  });

  // ── Flujo completo de creación ─────────────────────────────────────────────

  testWidgets('crea un hábito y muestra el mensaje de éxito', (tester) async {
    await openForm(tester);
    await tester.enterText(nameField(), '  Tomar   agua ');
    await tester.enterText(goalField(), '8 vasos al día');
    await scrollAndTap(tester, find.text('Activar Recordatorios'));

    await scrollAndTap(tester, find.text('Guardar'));

    expect(find.text('Hábito creado correctamente'), findsOneWidget);
    final saved = provider.habits.single;
    expect(saved.name, 'Tomar agua');
    expect(saved.goal, '8 vasos al día');
    // goalPerDay siempre es 1 cuando se usa el campo goal
    expect(saved.goalPerDay, 1);
    expect(saved.type, HabitType.frecuente);
    expect(saved.remindersEnabled, isFalse);
  });

  testWidgets('un hábito fugaz se guarda sin repetición', (tester) async {
    await openForm(tester);
    await tester.tap(find.text('Habito fugaz'));
    await tester.pumpAndSettle();

    expect(find.text('Repetir'), findsNothing);

    await tester.enterText(nameField(), 'Ir al banco');
    await tester.enterText(goalField(), 'Completar trámite');
    await scrollAndTap(tester, find.text('Activar Recordatorios'));
    await scrollAndTap(tester, find.text('Guardar'));

    final saved = provider.habits.single;
    expect(saved.type, HabitType.fugaz);
    expect(saved.repeat, isNull);
    expect(saved.days, isEmpty);
  });

  testWidgets('muestra el error si el nombre ya existe', (tester) async {
    await provider.addHabit(buildHabit(name: 'Leer'));
    await openForm(tester);
    await tester.enterText(nameField(), 'leer');
    await tester.enterText(goalField(), '20 páginas');
    await scrollAndTap(tester, find.text('Activar Recordatorios'));

    await scrollAndTap(tester, find.text('Guardar'));
    expect(find.text('Ya tienes un hábito con ese nombre'), findsOneWidget);
    expect(provider.habits, hasLength(1));
  });

  // ── Modo editar ────────────────────────────────────────────────────────────

  testWidgets('modo editar: carga el nombre y la meta guardada', (tester) async {
    // Hábito con meta de texto
    await provider.addHabit(
      buildHabit(name: 'Meditar').copyWith(goal: '10 minutos'),
    );
    final habit = provider.habits.single;
    await openForm(tester, habit: habit);

    expect(find.text('Editar Hábito'), findsOneWidget);
    // Al editar ya no se puede cambiar el tipo
    expect(find.text('Habito fugaz'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Meditar'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '10 minutos'), findsOneWidget);

    await tester.enterText(nameField(), 'Meditar 10 min');
    await scrollAndTap(tester, find.text('Guardar cambios'));

    expect(find.text('Hábito actualizado correctamente'), findsOneWidget);
    expect(provider.habits.single.name, 'Meditar 10 min');
    expect(provider.habits.single.id, habit.id);
  });

  testWidgets('modo editar: hábito sin meta carga el campo vacío', (tester) async {
    await provider.addHabit(buildHabit(name: 'Meditar'));
    final habit = provider.habits.single;
    await openForm(tester, habit: habit);

    // El campo de meta debe estar vacío (goal=null)
    final goalWidget = tester.widget<TextFormField>(goalField());
    expect(goalWidget.controller?.text ?? '', isEmpty);
  });
}
