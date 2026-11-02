// se prueba de widget del formulario nuevo o editar hábito
// Aquí sí construimos la pantalla de verdad, pero con el provider
// conectado a la fuente fake, así no se toca supabase

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

  /// Pone la pantalla dentro del provider, como hace AppProviders en la app
  Future<void> openForm(WidgetTester tester, {Habit? habit}) async {
    // Pantalla de 360 px de ancho, el celular más angosto que pedimos
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

  /// Como el formulario es largo, primero hacemos scroll hasta el widget
  /// y después lo tocamos
  Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
    // Quitamos el focus del campo de texto, como si el usuario cerrara el
    // teclado. Si no, Flutter regresa el scroll al campo que tiene el foco
    FocusManager.instance.primaryFocus?.unfocus();
    // Cerramos cualquier SnackBar de un intento anterior, porque sale
    // abajo y puede tapar el botón de guardar
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
  Finder goalField() => find.byType(TextFormField).last;

  testWidgets('muestra "Nuevo Hábito" con el toggle de tipo', (tester) async {
    await openForm(tester);

    expect(find.text('Nuevo Hábito'), findsOneWidget);
    expect(find.text('Habito Frecuente'), findsOneWidget);
    expect(find.text('Habito fugaz'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
    expect(find.text('El nombre debe incluir al menos una letra'),
        findsOneWidget);

    await tester.enterText(nameField(), 'Agua @@');
    await tester.pump();
    expect(find.text('Usa solo letras, números y signos básicos'),
        findsOneWidget);
  });

  testWidgets('valida la meta entre 1 y 99', (tester) async {
    await openForm(tester);

    await tester.enterText(goalField(), '0');
    await tester.pump();
    expect(find.text('La meta tiene que ser al menos 1'), findsOneWidget);

    await tester.enterText(goalField(), '');
    await tester.pump();
    expect(find.text('Escribe la meta diaria'), findsOneWidget);
  });

  testWidgets('con recordatorios activos pide la hora', (tester) async {
    await openForm(tester);
    await tester.enterText(nameField(), 'Tomar agua');

    await scrollAndTap(tester, find.text('Guardar'));

    expect(find.text('Elige la hora del recordatorio'), findsOneWidget);
    expect(provider.habits, isEmpty);
  });

  testWidgets('semanal sin días no se guarda', (tester) async {
    await openForm(tester);
    await tester.enterText(nameField(), 'Correr');
    await scrollAndTap(tester, find.text('Activar Recordatorios'));
    await scrollAndTap(tester, find.text('Semanalmente'));

    await scrollAndTap(tester, find.text('Guardar'));
    expect(find.text('Elige al menos un día de la semana'), findsOneWidget);
    await scrollAndTap(tester, find.bySemanticsLabel('Lunes'));
    await scrollAndTap(tester, find.text('Guardar'));

    expect(provider.habits.single.repeat, HabitRepeat.semanalmente);
    expect(provider.habits.single.days, {DateTime.monday});
  });

  testWidgets('crea un hábito y muestra el mensaje de éxito', (tester) async {
    await openForm(tester);
    await tester.enterText(nameField(), '  Tomar   agua ');
    await tester.enterText(goalField(), '3');
    await scrollAndTap(tester, find.text('Activar Recordatorios'));

    await scrollAndTap(tester, find.text('Guardar'));

    expect(find.text('Hábito creado correctamente'), findsOneWidget);
    final saved = provider.habits.single;
    expect(saved.name, 'Tomar agua');
    expect(saved.goalPerDay, 3);
    expect(saved.type, HabitType.frecuente);
    expect(saved.remindersEnabled, isFalse);
  });

  testWidgets('un hábito fugaz se guarda sin repetición', (tester) async {
    await openForm(tester);
    await tester.tap(find.text('Habito fugaz'));
    await tester.pumpAndSettle();

    // En fugaz no existe la sección de repetición
    expect(find.text('Repetir'), findsNothing);

    await tester.enterText(nameField(), 'Ir al banco');
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
    await scrollAndTap(tester, find.text('Activar Recordatorios'));

    await scrollAndTap(tester, find.text('Guardar'));
    expect(find.text('Ya tienes un hábito con ese nombre'), findsOneWidget);
    expect(provider.habits, hasLength(1));
  });

  testWidgets('modo editar: datos cargados y "Guardar cambios"',
      (tester) async {
    await provider.addHabit(buildHabit(name: 'Meditar', goalPerDay: 2));
    final habit = provider.habits.single;
    await openForm(tester, habit: habit);

    expect(find.text('Editar Hábito'), findsOneWidget);
    // Al editar ya no se puede cambiar el tipo
    expect(find.text('Habito fugaz'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Meditar'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '2'), findsOneWidget);

    await tester.enterText(nameField(), 'Meditar 10 min');
    await scrollAndTap(tester, find.text('Guardar cambios'));

    expect(find.text('Hábito actualizado correctamente'), findsOneWidget);
    expect(provider.habits.single.name, 'Meditar 10 min');
    expect(provider.habits.single.id, habit.id);
  });
}