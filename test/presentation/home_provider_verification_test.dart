// pruebas de lo que hace el HomeProvider con la foto cuando se cierra el
// panel o se manda otra foto antes de que llegue la respuesta

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/home_habit.dart';
import 'package:habuu/data/repositories/home_repository.dart';
import 'package:habuu/presentation/models/home/evidence_check.dart';
import 'package:habuu/presentation/providers/home_provider.dart';

import '../fakes/fake_daily_summary_data_source.dart';
import '../fakes/fake_evidence_data_source.dart';
import '../fakes/fake_home_data_source.dart';
import '../fakes/fake_photo_verifier.dart';

final _photo = Uint8List.fromList([1, 2, 3]);
final _otherPhoto = Uint8List.fromList([4, 5, 6]);

final _habit = HomeHabit(
  id: 'h1',
  name: 'Leer',
  iconKey: 'book',
  type: HomeHabitType.oneTime,
  createdDate: DateTime(2026, 11, 2),
);

const _delay = Duration(milliseconds: 20);

/// Espera a que el verificador falso conteste.
Future<void> waitForAnswer() =>
    Future<void>.delayed(_delay + const Duration(milliseconds: 30));

void main() {
  late FakeHomeDataSource homeDs;
  late FakeEvidenceDataSource evidence;
  late FakePhotoVerifier verifier;
  late HomeProvider home;

  setUp(() async {
    homeDs = FakeHomeDataSource(habits: [_habit]);
    evidence = FakeEvidenceDataSource();
    verifier = FakePhotoVerifier(delay: _delay);
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
    await home.load();
  });

  test('la foto se sube antes de verificar y el hábito espera', () async {
    await home.submitEvidence('h1', _photo);

    expect(evidence.photos, hasLength(1));
    expect(home.evidenceCheckFor('h1')?.status, VerificationStatus.verificando);
    expect(homeDs.savedLogs, isEmpty);

    await waitForAnswer();
    expect(home.evidenceCheckFor('h1')?.status, VerificationStatus.verificado);
    expect(homeDs.savedLogs, hasLength(1));
  });

  test('si cierra el panel y la foto no coincide, se borra', () async {
    verifier.result = FakePhotoVerifier.notMatching();
    await home.submitEvidence('h1', _photo);

    home.dismissEvidence('h1');
    await waitForAnswer();

    expect(evidence.photos, isEmpty);
    expect(homeDs.savedLogs, isEmpty);
    expect(home.evidenceCheckFor('h1'), isNull);
  });

  test('si cierra el panel y la foto coincide, el hábito se marca '
      'igual', () async {
    await home.submitEvidence('h1', _photo);

    home.dismissEvidence('h1');
    await waitForAnswer();

    expect(homeDs.savedLogs, hasLength(1));
    expect(home.habits.single.isDone, isTrue);
    expect(evidence.photos, hasLength(1));
  });

  test('si manda otra foto, la respuesta de la primera se ignora', () async {
    verifier.result = FakePhotoVerifier.notMatching();
    await home.submitEvidence('h1', _photo);
    await waitForAnswer();
    expect(
      home.evidenceCheckFor('h1')?.status,
      VerificationStatus.noConfirmado,
    );

    // La segunda tarda más; mientras, la primera ya no debe cambiar nada.
    verifier
      ..result = FakePhotoVerifier.matching()
      ..delay = const Duration(milliseconds: 60);
    await home.submitEvidence('h1', _otherPhoto);
    expect(home.evidenceCheckFor('h1')?.photo, same(_otherPhoto));

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(home.evidenceCheckFor('h1')?.status, VerificationStatus.verificado);
    expect(homeDs.savedLogs, hasLength(1));
  });

  test('si la subida falla, devuelve el mensaje y no verifica', () async {
    evidence.errorToThrow = Exception('sin red');

    final error = await home.submitEvidence('h1', _photo);

    expect(error, isNotNull);
    expect(home.evidenceCheckFor('h1'), isNull);
    expect(verifier.verifiedPaths, isEmpty);
  });
}
