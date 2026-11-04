// pantalla Perfil > Usuario con el repository sobre una fuente falsa

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/datasources/profile_data_source.dart';
import 'package:habuu/data/models/user_profile.dart';
import 'package:habuu/data/repositories/profile_repository.dart';
import 'package:habuu/presentation/providers/profile_provider.dart';
import 'package:habuu/presentation/screens/profile/user_screen.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_profile_data_source.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  late FakeProfileDataSource profiles;

  setUp(() {
    profiles = FakeProfileDataSource(
      profile: const UserProfile(
        id: 'user-1',
        email: 'ana@correo.com',
        fullName: 'Ana López',
        phone: '7123 4567',
      ),
    );
  });

  Future<ProfileProvider> openScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final provider = ProfileProvider(ProfileRepository(profiles))..load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: UserScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  Finder saveButton() => find.widgetWithText(ElevatedButton, 'Guardar cambios');

  bool saveEnabled(WidgetTester tester) =>
      tester.widget<ElevatedButton>(saveButton()).onPressed != null;

  testWidgets('muestra los datos guardados del usuario', (tester) async {
    await openScreen(tester);

    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('ana@correo.com'), findsOneWidget);
    expect(find.text('7123 4567'), findsOneWidget);
    expect(find.text('AL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guardar se activa solo cuando hay cambios', (tester) async {
    await openScreen(tester);
    expect(saveEnabled(tester), isFalse);

    await tester.enterText(find.text('Ana López'), 'Ana María');
    await tester.pump();
    expect(saveEnabled(tester), isTrue);

    // Volver al valor original ya no cuenta como cambio.
    await tester.enterText(find.text('Ana María'), 'Ana López');
    await tester.pump();
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('guarda los cambios y avisa', (tester) async {
    await openScreen(tester);

    await tester.enterText(find.text('Ana López'), '  Ana María  ');
    await tester.tap(find.byType(DropdownButtonFormField<Gender>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Femenino').last);
    await tester.pumpAndSettle();

    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    expect(profiles.stored.fullName, 'Ana María');
    expect(profiles.stored.gender, Gender.female);
    expect(profiles.stored.phone, '7123 4567');
    expect(find.text('Cambios guardados'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    // El avatar toma las iniciales del nombre nuevo.
    expect(find.text('AM'), findsOneWidget);
  });

  testWidgets('con el nombre vacío no guarda', (tester) async {
    await openScreen(tester);

    await tester.enterText(find.text('Ana López'), '   ');
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu nombre'), findsOneWidget);
    expect(profiles.saveCalls, 0);
  });

  testWidgets('un teléfono con pocos dígitos muestra el error', (tester) async {
    await openScreen(tester);

    await tester.enterText(find.text('7123 4567'), '7123');
    await tester.pump();

    expect(
      find.text('El teléfono debe tener entre 8 y 15 dígitos'),
      findsOneWidget,
    );
  });

  testWidgets('si guardar falla, muestra el mensaje', (tester) async {
    await openScreen(tester);
    profiles.nextError = const ProfileDataException(
      'Revisa tu conexión e inténtalo de nuevo',
    );

    await tester.enterText(find.text('Ana López'), 'Ana María');
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    expect(
      find.text('Revisa tu conexión e inténtalo de nuevo'),
      findsOneWidget,
    );
    expect(profiles.stored.fullName, 'Ana López');
  });

  testWidgets('si no carga, muestra el error y deja reintentar', (
    tester,
  ) async {
    profiles.nextError = const ProfileDataException(
      'No se pudo cargar tu perfil',
    );
    await openScreen(tester);

    expect(find.text('No se pudo cargar tu perfil'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Ana López'), findsOneWidget);
  });
}
