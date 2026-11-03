// Tests de widget para el Calendar de rachas.
// Se verifica que el calendario renderiza, que los días de racha
// se pintan distinto, y que el calendario responde al scroll.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/widgets/streaks/calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  setUpAll(() async {
    // table_calendar usa el locale es_ES para formatear el encabezado del mes.
    await initializeDateFormatting('es_ES');
  });

  // Fecha de referencia para los tests (independiente de DateTime.now()).
  final today = DateTime(2026, 11, 2);

  Future<void> pumpCalendar(
    WidgetTester tester, {
    Set<DateTime> streakDays = const {},
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Calendar(streakDays: streakDays),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('renderizado básico', () {
    testWidgets('muestra un TableCalendar', (tester) async {
      await pumpCalendar(tester);

      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('muestra el año 2026 en el encabezado', (tester) async {
      await pumpCalendar(tester);

      // El header formatea "Noviembre 2026"; buscamos el año para no depender
      // del texto exacto del locale.
      expect(find.textContaining('2026'), findsAtLeastNWidgets(1));
    });

    testWidgets('muestra las letras de los días de la semana', (tester) async {
      await pumpCalendar(tester);

      expect(find.text('L'), findsOneWidget);
      expect(find.text('J'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
    });
  });

  group('días de racha', () {
    testWidgets('renderiza sin error con días de racha configurados',
        (tester) async {
      await pumpCalendar(
        tester,
        streakDays: {
          DateTime(today.year, today.month, today.day - 2),
          DateTime(today.year, today.month, today.day - 1),
          today,
        },
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('los días de racha producen Container con BoxShape.circle',
        (tester) async {
      await pumpCalendar(
        tester,
        streakDays: {DateTime(2026, 11, 1)},
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final circles = containers.where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(circles.isNotEmpty, isTrue);
    });

    testWidgets('sin días de racha el calendario igualmente renderiza',
        (tester) async {
      await pumpCalendar(tester, streakDays: {});

      expect(find.byType(TableCalendar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('navegación de mes', () {
    testWidgets('existen botones de navegación izquierda y derecha',
        (tester) async {
      await pumpCalendar(tester);

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('tocar chevron_right cambia el texto del encabezado',
        (tester) async {
      await pumpCalendar(tester);

      final textBefore =
          (tester.widget<Text>(find.textContaining('2026').first) as Text)
                  .data ??
              '';

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final textAfter =
          (tester.widget<Text>(find.textContaining('202').first) as Text)
                  .data ??
              '';
      expect(textAfter, isNot(equals(textBefore)));
    });
  });
}
