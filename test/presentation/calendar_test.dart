import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/widgets/streaks/calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('es_ES'));

  Future<void> pump(WidgetTester t, {Set<DateTime> days = const {}}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: Calendar(streakDays: days))),
    ));
    await t.pumpAndSettle();
  }

  testWidgets('renderiza TableCalendar', (t) async {
    await pump(t);
    expect(find.byType(TableCalendar), findsOneWidget);
  });

  testWidgets('muestra el año en el encabezado', (t) async {
    await pump(t);
    expect(find.textContaining('2026'), findsAtLeastNWidgets(1));
  });

  testWidgets('botones de navegación presentes', (t) async {
    await pump(t);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('funciona con días de racha', (t) async {
    await pump(t, days: {DateTime(2026, 11, 1), DateTime(2026, 11, 2)});
    expect(t.takeException(), isNull);
    expect(find.byType(TableCalendar), findsOneWidget);
  });
}
