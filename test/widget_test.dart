// No probamos HabuuApp completa porque main() se conecta a supabase, y
// las pruebas tienen que correr sin internet, para eso tenemos fake

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/models/habit.dart';
import 'package:habuu/data/repositories/habit_repository.dart';
import 'package:habuu/presentation/providers/habits_provider.dart';
import 'package:habuu/presentation/screens/habits/habit_success_screen.dart';
import 'package:habuu/presentation/screens/habits/habits_screen.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_habit_data_source.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  /// Simula un celular de [width] px de ancho.
  void setScreen(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('HabitSuccessScreen', () {
    testWidgets('muestra el mensaje y "Aceptar" regresa', (tester) async {
      setScreen(tester, 360);
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

  group('HabitsScreen ("Tus Hábitos")', () {
    late HabitsProvider provider;

    setUp(() async {
      provider = HabitsProvider(
        HabitRepository(
          FakeHabitDataSource(initialHabits: [
            buildHabit(id: '1', name: 'Tomar agua', goalPerDay: 2),
            buildHabit(id: '2', name: 'Ir al banco', type: HabitType.fugaz),
          ]),
        ),
      );
      await provider.loadHabits();
    });

    Future<void> openList(WidgetTester tester, double width) async {
      setScreen(tester, width);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HabitsScreen()),
        ),
      );
    }

    // Probamos en el celular más angosto y el normal
    for (final width in [360.0, 440.0]) {
      testWidgets('el toggle filtra por tipo a $width px', (tester) async {
        await openList(tester, width);

        expect(find.text('Tus Hábitos'), findsOneWidget);
        expect(find.text('Tomar agua'), findsOneWidget);
        expect(find.text('2 VECES AL DÍA · SALUD'), findsOneWidget);
        expect(find.text('Ir al banco'), findsNothing);

        await tester.tap(find.text('Habito fugaz'));
        await tester.pumpAndSettle();

        expect(find.text('Ir al banco'), findsOneWidget);
        expect(find.text('Tomar agua'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('al borrar pide confirmación', (tester) async {
      await openList(tester, 360);

      // Se desliza la tarjeta a la izquierda
      await tester.drag(find.text('Tomar agua'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('¿Estás seguro?'), findsOneWidget);

      // Si cancela, el hábito sigue ahí
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(provider.habits, hasLength(2));

      await tester.drag(find.text('Tomar agua'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();

      expect(provider.frequentHabits, isEmpty);
      expect(find.text('Aún no tienes hábitos frecuentes'), findsOneWidget);
    });
  });
}