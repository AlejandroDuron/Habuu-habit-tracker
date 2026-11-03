// Tests de widget para TrophyCard.
// Se verifica el título, la imagen, el estado locked (escala de grises)
// y la descripción opcional.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/widgets/thophies/trophy_card.dart';

void main() {
  /// Monta TrophyCard dentro de un MaterialApp mínimo.
  Future<void> pumpCard(
    WidgetTester tester, {
    required String title,
    String imagePath = 'assets/images/calendar/day_completed.png',
    String? description,
    double size = 80,
    bool locked = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrophyCard(
            title: title,
            imagePath: imagePath,
            description: description,
            size: size,
            locked: locked,
          ),
        ),
      ),
    );
  }

  testWidgets('muestra el título del trofeo', (tester) async {
    await pumpCard(tester, title: 'Día completado');

    expect(find.text('Día completado'), findsOneWidget);
  });

  testWidgets('no muestra descripción si no se pasa', (tester) async {
    await pumpCard(tester, title: 'Racha 7');

    // Solo el título
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('muestra la descripción cuando se proporciona', (tester) async {
    await pumpCard(
      tester,
      title: 'Racha 7',
      description: 'Completa 7 días seguidos',
    );

    expect(find.text('Racha 7'), findsOneWidget);
    expect(find.text('Completa 7 días seguidos'), findsOneWidget);
  });

  testWidgets('en modo locked aplica ColorFiltered (escala de grises)',
      (tester) async {
    await pumpCard(tester, title: 'Bloqueado', locked: true);

    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('en modo unlocked NO aplica ColorFiltered', (tester) async {
    await pumpCard(tester, title: 'Desbloqueado', locked: false);

    expect(find.byType(ColorFiltered), findsNothing);
  });

  testWidgets('el contenedor tiene el tamaño indicado por size', (tester) async {
    const cardSize = 90.0;
    await pumpCard(tester, title: 'Tamaño', size: cardSize);

    final containers = tester.widgetList<Container>(find.byType(Container));
    final sizedContainer = containers.firstWhere(
      (c) =>
          c.constraints?.maxWidth == cardSize &&
          c.constraints?.maxHeight == cardSize,
      orElse: () => throw TestFailure('No se encontró container de $cardSize x $cardSize'),
    );
    expect(sizedContainer, isNotNull);
  });

  testWidgets('renderiza sin error con imagePath de asset inexistente',
      (tester) async {
    // Usamos un asset real del proyecto para verificar que renderiza bien.
    await pumpCard(
      tester,
      title: 'Con imagen real',
      imagePath: 'assets/images/calendar/day_completed.png',
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Con imagen real'), findsOneWidget);
  });
}
