// resumen diario que no guarda nada, solo para armar el HomeRepository

import 'package:habuu/data/datasources/daily_summary_data_source.dart';

class FakeDailySummaryDataSource implements DailySummaryDataSource {
  final List<DateTime> completedDays = [];

  @override
  Future<void> markDayComplete(DateTime day) async => completedDays.add(day);

  @override
  Future<void> markDayIncomplete(DateTime day) async =>
      completedDays.remove(day);

  @override
  Future<Set<DateTime>> getCompletedDays({required DateTime since}) async =>
      completedDays.toSet();

  @override
  Future<int> getTotalCompletedDays() async => completedDays.length;
}
