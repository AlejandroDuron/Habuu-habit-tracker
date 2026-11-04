// pruebas del panel de la foto en el Home con cada resultado de la
// verificación. La foto no se elige con la galería (no hay en las pruebas),
// se manda directo con el provider y se revisa lo que muestra la pantalla.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/datasources/habit_photo_verifier.dart';
import 'package:habuu/data/models/habit_log.dart';
import 'package:habuu/data/models/home_habit.dart';
import 'package:habuu/data/repositories/home_repository.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';
import 'package:habuu/presentation/providers/home_provider.dart';
import 'package:habuu/presentation/providers/trophies_provider.dart';
import 'package:habuu/presentation/providers/verification_settings_provider.dart';
import 'package:habuu/presentation/screens/home/home_screen.dart';
import 'package:habuu/presentation/widgets/shared/scanner_overlay.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_daily_summary_data_source.dart';
import '../fakes/fake_evidence_data_source.dart';
import '../fakes/fake_home_data_source.dart';
import '../fakes/fake_photo_verifier.dart';
import '../fakes/fake_trophy_data_source.dart';
import '../fakes/fake_verification_preferences.dart';

// Un PNG de 1x1, para que Image.memory tenga algo que dibujar.
final _photo = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

final _habit = HomeHabit(
  id: 'h1',
  name: 'Leer',
  iconKey: 'book',
  type: HomeHabitType.recurring,
  frequency: HabitFrequency.weekly,
  daysOfWeek: const {1, 2, 3, 4, 5, 6, 7},
  createdDate: DateTime(2026, 10, 1),
);

const _noMatch = 'No pudimos confirmar que la foto corresponda al hábito';

/// Avanza el reloj de a poco para que la franja termine su pasada y la capa
/// se desvanezca (cada animación necesita varios cuadros).
Future<void> _letScannerFinish(WidgetTester tester) async {
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  late FakeHomeDataSource homeDs;
  late FakeEvidenceDataSource evidence;
  late FakePhotoVerifier verifier;
  late HomeProvider home;

  setUp(() {
    homeDs = FakeHomeDataSource(habits: [_habit]);
    evidence = FakeEvidenceDataSource();
    verifier = FakePhotoVerifier();
    home = HomeProvider(
      HomeRepository(
        homeDs,
        evidence,
        FakeDailySummaryDataSource(),
        verifier: verifier,
        compressPhoto: (photo) async => photo,
      ),
      clock: () => DateTime(2026, 11, 2),
    );
  });

  final doneButton = find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == 'Marcar como cumplido',
  );
  final scanner = find.byKey(ScannerOverlay.overlayKey);

  /// Abre el Home con los hábitos ya cargados.
  Future<void> pumpHome(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) =>
                TrophiesProvider(TrophyRepository(FakeTrophyDataSource())),
          ),
          ChangeNotifierProvider.value(value: home),
          ChangeNotifierProvider(
            create: (_) => VerificationSettingsProvider(
              FakeVerificationPreferences(value: true),
            ),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
          home: const HomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  /// Abre el Home y el panel de la foto del hábito.
  Future<void> openPanel(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    await pumpHome(tester, reduceMotion: reduceMotion);
    await tester.tap(doneButton);
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('mientras verifica, el escáner tapa la foto y se quita al '
      'llegar el resultado', (tester) async {
    verifier.delay = const Duration(seconds: 1);
    await openPanel(tester);

    await home.submitEvidence('h1', _photo);
    await tester.pump(const Duration(milliseconds: 100));

    expect(scanner, findsOneWidget);
    expect(find.text('Revisando que la foto sea del hábito…'), findsOneWidget);
    expect(homeDs.savedLogs, isEmpty);

    // A media pasada la franja sigue ahí.
    await tester.pump(const Duration(milliseconds: 500));
    expect(scanner, findsOneWidget);

    // Llega la respuesta: termina la pasada y se desvanece.
    await tester.pump(const Duration(milliseconds: 500));
    await _letScannerFinish(tester);
    expect(scanner, findsNothing);
    expect(find.text('Verificado'), findsOneWidget);
  });

  testWidgets('verificado: marca el hábito y muestra el motivo', (
    tester,
  ) async {
    await openPanel(tester);

    await home.submitEvidence('h1', _photo);
    await tester.pump();
    await _letScannerFinish(tester);

    expect(find.text('Verificado'), findsOneWidget);
    expect(find.text('Se ve un libro abierto.'), findsOneWidget);
    expect(homeDs.savedLogs.single.evidencePath, isNotNull);
    expect(home.habits.single.isDone, isTrue);

    // "Listo" cierra el panel y la foto se queda, porque ya es evidencia.
    await tester.tap(find.text('Listo'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Verificado'), findsNothing);
    expect(evidence.photos, hasLength(1));
  });

  testWidgets('no confirmado: avisa y no marca el hábito', (tester) async {
    verifier.result = FakePhotoVerifier.notMatching();
    await openPanel(tester);

    await home.submitEvidence('h1', _photo);
    await tester.pump();
    await _letScannerFinish(tester);

    expect(find.text('No confirmado'), findsOneWidget);
    expect(find.text(_noMatch), findsOneWidget);
    expect(
      find.text('La foto muestra una calle, no un libro.'),
      findsOneWidget,
    );
    expect(homeDs.savedLogs, isEmpty);
    expect(home.habits.single.isDone, isFalse);
    // Puede elegir otra foto.
    expect(find.text('Cambiar Archivo'), findsOneWidget);

    // Si cierra el panel, la foto que no sirvió se borra.
    await tester.tap(doneButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text(_noMatch), findsNothing);
    expect(evidence.photos, isEmpty);
  });

  testWidgets('no se pudo verificar: se puede guardar sin verificar', (
    tester,
  ) async {
    verifier.failure = VerificationFailure.sinConexion;
    await openPanel(tester);

    await home.submitEvidence('h1', _photo);
    await tester.pump();
    await _letScannerFinish(tester);

    expect(find.text('No se pudo verificar'), findsOneWidget);
    expect(find.text(VerificationFailure.sinConexion.message), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(homeDs.savedLogs, isEmpty);

    await tester.tap(find.text('Guardar sin verificar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(homeDs.savedLogs, hasLength(1));
    expect(home.habits.single.isDone, isTrue);
    expect(find.text('No se pudo verificar'), findsNothing);
  });

  testWidgets('no se pudo verificar: "Reintentar" vuelve a revisar la foto', (
    tester,
  ) async {
    verifier.failure = VerificationFailure.timeout;
    await openPanel(tester);

    await home.submitEvidence('h1', _photo);
    await tester.pump();
    await _letScannerFinish(tester);
    expect(find.text(VerificationFailure.timeout.message), findsOneWidget);

    verifier.failure = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await _letScannerFinish(tester);

    expect(find.text('Verificado'), findsOneWidget);
    // Dos del primer intento (con el reintento automático) y uno a mano.
    expect(verifier.verifiedPaths, hasLength(3));
    expect(home.habits.single.isDone, isTrue);
  });

  testWidgets('con reducir movimiento, muestra un indicador en vez de la '
      'franja', (tester) async {
    verifier.delay = const Duration(seconds: 1);
    await openPanel(tester, reduceMotion: true);

    await home.submitEvidence('h1', _photo);
    await tester.pump(const Duration(milliseconds: 100));

    expect(scanner, findsOneWidget);
    expect(find.text(ScannerOverlay.label), findsOneWidget);
    expect(
      find.descendant(
        of: scanner,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 1));
    await _letScannerFinish(tester);
    expect(scanner, findsNothing);
  });

  group('hábito ya cumplido', () {
    const path = 'user-1/h1/2026-11-02.jpg';
    final doneMark = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Hábito cumplido',
    );
    final evidenceImage = find.byWidgetPredicate(
      (w) => w is Image && w.semanticLabel == 'Foto de evidencia',
    );

    Future<void> markedWithPhoto() async {
      await homeDs.saveLog(
        habitId: 'h1',
        day: DateTime(2026, 11, 2),
        status: LogStatus.done,
        evidencePath: path,
      );
    }

    testWidgets('al tocarlo otra vez se ve la foto que se subió', (
      tester,
    ) async {
      await markedWithPhoto();
      evidence.photos[path] = _photo;
      await pumpHome(tester);

      await tester.tap(doneMark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(evidenceImage, findsOneWidget);
    });

    testWidgets('recién verificada, la foto se ve sin volver a descargarla', (
      tester,
    ) async {
      await openPanel(tester);
      await home.submitEvidence('h1', _photo);
      await tester.pump();
      await _letScannerFinish(tester);
      await tester.tap(find.text('Listo'));
      await tester.pump(const Duration(milliseconds: 300));

      // Si intentara descargarla, fallaría.
      evidence.errorToThrow = Exception('sin red');
      await tester.tap(doneMark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(evidenceImage, findsOneWidget);
    });

    testWidgets('si no se puede descargar, avisa en vez de romperse', (
      tester,
    ) async {
      await markedWithPhoto();
      await pumpHome(tester);

      await tester.tap(doneMark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('No se pudo cargar la foto. Revisa tu conexión.'),
        findsOneWidget,
      );
      expect(evidenceImage, findsNothing);
    });
  });
}
