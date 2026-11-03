// AnimatedFrog tiene animaciones infinitas → se usa pump(duration).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/models/streak_data.dart';
import 'package:habuu/data/repositories/home_repository.dart';
import 'package:habuu/data/repositories/streak_repository.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';
import 'package:habuu/presentation/providers/home_provider.dart';
import 'package:habuu/presentation/providers/streaks_provider.dart';
import 'package:habuu/presentation/providers/trophies_provider.dart';
import 'package:habuu/presentation/screens/streaks/streaks_screen.dart';
import 'package:habuu/presentation/widgets/streaks/calendar.dart';
import 'package:habuu/presentation/widgets/streaks/streak_header.dart';
import 'package:habuu/presentation/widgets/streaks/throphies_sumary.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../fakes/fake_daily_summary_data_source.dart';
import '../fakes/fake_evidence_data_source.dart';
import '../fakes/fake_home_data_source.dart';
import '../fakes/fake_photo_verifier.dart';
import '../fakes/fake_streak_data_source.dart';
import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUpAll(() async => initializeDateFormatting('es_ES'));

  const settle = Duration(milliseconds: 300);

  Future<void> pump(WidgetTester t, {
    StreakData? data,
    bool fail = false,
    Duration streakDelay = Duration.zero,
  }) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);

    final trophies = TrophiesProvider(TrophyRepository(FakeTrophyDataSourceFull()));
    final streaks = StreaksProvider(
      StreakRepository(FakeStreakDataSource(data: data, shouldFail: fail, delay: streakDelay)),
      trophies: trophies,
    );
    final home = HomeProvider(
      HomeRepository(FakeHomeDataSource(), FakeEvidenceDataSource(),
          FakeDailySummaryDataSource(), verifier: FakePhotoVerifier()),
      trophies: trophies,
    );
    await t.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: streaks),
      ChangeNotifierProvider.value(value: trophies),
      ChangeNotifierProvider.value(value: home),
    ], child: const MaterialApp(home: Scaffold(body: StreakScreen()))));
  }

  testWidgets('muestra loading indicator al cargar', (t) async {
    await pump(t, streakDelay: const Duration(milliseconds: 100));
    await t.pump(); await t.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await t.pump(const Duration(milliseconds: 200));
  });

  testWidgets('tras cargar muestra StreakHeader, Calendar y TrophiesSummary', (t) async {
    await pump(t, data: const StreakData.empty());
    await t.pump(); await t.pump(settle);
    expect(find.byType(StreakHeader), findsOneWidget);
    expect(find.byType(Calendar), findsOneWidget);
    expect(find.byType(TrophiesSummary), findsOneWidget);
  });

  testWidgets('muestra el número de días de racha', (t) async {
    await pump(t, data: StreakData(currentStreak: 7, streakDays: {}));
    await t.pump(); await t.pump(settle);
    expect(find.text('7'), findsAtLeastNWidgets(1));
    expect(find.text('Días de racha'), findsOneWidget);
  });

  testWidgets('el Calendar recibe los streakDays del provider', (t) async {
    final days = {DateTime(2026, 11, 1)};
    await pump(t, data: StreakData(currentStreak: 1, streakDays: days));
    await t.pump(); await t.pump(settle);
    final cal = t.widget<Calendar>(find.byType(Calendar));
    expect(cal.streakDays, days);
    expect(find.byType(TableCalendar), findsOneWidget);
  });

  testWidgets('error de racha no lanza excepción', (t) async {
    await pump(t, fail: true);
    await t.pump(); await t.pump(settle);
    expect(t.takeException(), isNull);
  });
}
