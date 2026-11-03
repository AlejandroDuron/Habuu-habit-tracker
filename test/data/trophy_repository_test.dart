import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/trophy.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';

import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  late FakeTrophyDataSourceFull ds;
  late TrophyRepository repo;

  setUp(() {
    ds = FakeTrophyDataSourceFull();
    repo = TrophyRepository(ds);
  });

  test('getTrophies separa earned y locked correctamente', () async {
    final earned = buildEarnedTrophy(trophy: buildTrophy(id: 'day_completed'));
    ds = FakeTrophyDataSourceFull(
      allTrophies: [buildTrophy(id: 'day_completed'), buildTrophy(id: 'streak_7')],
      earnedTrophies: [earned],
    );
    repo = TrophyRepository(ds);

    final r = await repo.getTrophies();
    expect(r.earned, hasLength(1));
    expect(r.locked, hasLength(1));
    expect(r.locked.first.id, 'streak_7');
  });

  test('checkDayCompleted no llama awardTrophy si allDone=false', () async {
    await repo.checkDayCompleted(allDone: false);
    expect(ds.awardCalls, isEmpty);
  });

  test('checkOneMonth no otorga si no han pasado 30 días', () async {
    final result = await repo.checkOneMonth(
      firstHabitDate: DateTime.now().subtract(const Duration(days: 10)),
    );
    expect(result, isNull);
  });

  test('checkOneMonth otorga si han pasado 30+ días', () async {
    ds.awardedTrophy = buildEarnedTrophy(trophy: buildTrophy(id: 'one_month'));
    final result = await repo.checkOneMonth(
      firstHabitDate: DateTime.now().subtract(const Duration(days: 35)),
    );
    expect(result, isNotNull);
  });
}
