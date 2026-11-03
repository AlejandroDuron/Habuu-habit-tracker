import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/widgets/thophies/trophy_card.dart';

void main() {
  Future<void> pump(WidgetTester t, {bool locked = false, String? description}) =>
      t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TrophyCard(
            title: 'Día completado',
            imagePath: 'assets/images/calendar/day_completed.png',
            description: description,
            locked: locked,
          ),
        ),
      ));

  testWidgets('muestra el título', (t) async {
    await pump(t);
    expect(find.text('Día completado'), findsOneWidget);
  });

  testWidgets('locked aplica ColorFiltered', (t) async {
    await pump(t, locked: true);
    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('unlocked no aplica ColorFiltered', (t) async {
    await pump(t, locked: false);
    expect(find.byType(ColorFiltered), findsNothing);
  });

  testWidgets('muestra descripción si se proporciona', (t) async {
    await pump(t, description: 'Completa el día');
    expect(find.text('Completa el día'), findsOneWidget);
  });
}
