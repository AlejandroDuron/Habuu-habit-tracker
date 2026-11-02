// No probamos HabuuApp completa porque main() se conecta a supabase, y
// las pruebas tienen que correr sin internet, para usamos los mocks (fakes)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/models/habit.dart';
import 'package:habuu/data/repositories/habit_repository.dart';
import 'package:habuu/presentation/providers/habits_provider.dart';
import 'package:habuu/presentation/screens/habits/habit_success_screen.dart';
import 'package:habuu/presentation/screens/habits/habits_list_screen.dart';
import 'package:habuu/presentation/widgets/shared/habit_card.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_habit_data_source.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;


  void setScreen(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('HabitSuccessScreen', () {
    testWidgets('muestra el mensaje y "Aceptar" regresa', (tester) async {
      setScreen(tester, 360);
      // Una pantalla con un botón que abre la de éxito, para poder
      // comprobar que aceptar nos devuelve a la pantalla anterior
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HabitSuccessScreen(
                      message: 'Hábito creado correctamente',
                    ),
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Hábito creado correctamente'), findsOneWidget);

      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(find.text('Hábito creado correctamente'), findsNothing);
      expect(find.text('Abrir'), findsOneWidget);
    });
  });

  group('HabitsListScreen ("Tus Hábitos")', () {
    late HabitsProvider provider;

    setUp(() async {
      provider = HabitsProvider(
        HabitRepository(
          FakeHabitDataSource(
            initialHabits: [
              buildHabit(
                id: '1',
                name: 'Tomar agua',
                goalPerDay: 2,
                category: HabitCategory.salud,
              ),
              buildHabit(
                id: '2',
                name: 'Ir al banco',
                type: HabitType.fugaz,
                category: HabitCategory.hogar,
              ),
            ],
          ),
        ),
      );
      await provider.loadHabits();
    });

    Future<void> openList(WidgetTester tester, double width) async {
      setScreen(tester, width);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HabitsListScreen()),
        ),
      );
    }

    // Probamos en el celular más angosto y en el normal
    for (final width in [360.0, 440.0]) {
      testWidgets('muestra los hábitos sin desbordarse a $width px', (
        tester,
      ) async {
        await openList(tester, width);

        expect(find.text('Tus Hábitos'), findsOneWidget);
        expect(find.text('Tomar agua'), findsOneWidget);
        expect(find.text('2 veces al día'), findsOneWidget);
        expect(find.text('Ir al banco'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('el chip "Fugaz" deja solo los fugaces', (tester) async {
      await openList(tester, 360);

      await tester.tap(find.text('Fugaz'));
      await tester.pumpAndSettle();

      expect(find.text('Ir al banco'), findsOneWidget);
      expect(find.text('Tomar agua'), findsNothing);

      // Tocar el boton de config "todo", quita los filtros. Hay dos todo en pantalla (el del
      // período y el chip), el chip es el último
      await tester.tap(find.text('Todo').last);
      await tester.pumpAndSettle();
      expect(find.text('Tomar agua'), findsOneWidget);
    });

    testWidgets('los chips de categoría salen de los hábitos', (tester) async {
      await openList(tester, 440);

      // Los chips están en una fila con scroll horizontal, arrastramos la pantalla
      // hasta que se vea el último chip, igual que haría el usuario
      final chipsRow = find.ancestor(
        of: find.text('Frecuente'),
        matching: find.byType(ListView),
      );
      await tester.dragUntilVisible(
        find.text('Salud'),
        chipsRow,
        const Offset(-100, 0),
      );

      // Solo aparecen las categorías que de verdad se usan
      expect(find.text('Salud'), findsOneWidget);
      expect(find.text('Hogar'), findsOneWidget);
      expect(find.text('Universidad'), findsNothing);

      await tester.tap(find.text('Salud'));
      await tester.pumpAndSettle();

      expect(find.text('Tomar agua'), findsOneWidget);
      expect(find.text('Ir al banco'), findsNothing);
    });

    testWidgets('"Mover" solo cambia el orden dentro del mismo tipo', (
      tester,
    ) async {

      provider = HabitsProvider(
        HabitRepository(
          FakeHabitDataSource(
            initialHabits: [
              buildHabit(
                id: 'a',
                name: 'Leer',
                createdAt: DateTime(2026, 11, 3),
              ),
              buildHabit(
                id: 'x',
                name: 'Pagar luz',
                type: HabitType.fugaz,
                createdAt: DateTime(2026, 11, 2),
              ),
              buildHabit(
                id: 'b',
                name: 'Correr',
                createdAt: DateTime(2026, 11, 1),
              ),
            ],
          ),
        ),
      );
      await provider.loadHabits();
      await openList(tester, 360);
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text('Leer'),
            matching: find.byType(SimpleHabitCard),
          ),
          matching: find.byIcon(Icons.more_vert_rounded),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mover'));
      await tester.pumpAndSettle();

      // En el diálogo solo debe ofrecer hábitos frecuentes, no el fugaz
      final dialog = find.byType(AlertDialog);
      expect(
        find.descendant(of: dialog, matching: find.text('Correr')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Pagar luz')),
        findsNothing,
      );

      await tester.tap(
        find.descendant(of: dialog, matching: find.text('Correr')),
      );
      await tester.pumpAndSettle();

      expect(provider.frequentHabits.map((h) => h.name), ['Correr', 'Leer']);
      // El fugaz no se movió
      expect(provider.fleetingHabits.single.name, 'Pagar luz');
    });

    testWidgets('eliminar desde el menú pide confirmación', (tester) async {
      await openList(tester, 360);

      // El botón de config que está dentro de la tarjeta de tomar agua
      final menuButton = find.descendant(
        of: find.ancestor(
          of: find.text('Tomar agua'),
          matching: find.byType(SimpleHabitCard),
        ),
        matching: find.byIcon(Icons.more_vert_rounded),
      );

      Future<void> openDeleteDialog() async {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();
      }

      await openDeleteDialog();
      expect(find.text('¿Eliminar hábito?'), findsOneWidget);

      // Si cancela, el hábito sigue ahí
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(provider.habits, hasLength(2));

      // Si confirma, se borra de la lista
      await openDeleteDialog();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(provider.habits.map((h) => h.name), ['Ir al banco']);
      expect(find.text('Tomar agua'), findsNothing);
    });
  });
}