// hábitos y registros del Home en memoria

import 'package:habuu/data/datasources/home_data_source.dart';
import 'package:habuu/data/models/habit_log.dart';
import 'package:habuu/data/models/home_habit.dart';
import 'package:habuu/utils/dates.dart';

class FakeHomeDataSource implements HomeDataSource {
  FakeHomeDataSource({List<HomeHabit> habits = const []})
    : habits = [...habits];

  final List<HomeHabit> habits;

  /// Lo que se guardó con saveLog, para revisarlo en las pruebas.
  final List<HabitLog> savedLogs = [];

  @override
  Future<List<HomeHabit>> getActiveHabits() async => habits;

  @override
  Future<List<HabitLog>> getLogsOn(DateTime day) async =>
      savedLogs.where((l) => l.logDate == dateOnly(day)).toList();

  @override
  Future<HabitLog> saveLog({
    required String habitId,
    required DateTime day,
    required LogStatus status,
    String? evidencePath,
  }) async {
    final log = HabitLog(
      id: 'log-${savedLogs.length + 1}',
      habitId: habitId,
      logDate: day,
      status: status,
      evidencePath: evidencePath,
    );
    savedLogs
      ..removeWhere((l) => l.habitId == habitId && l.logDate == log.logDate)
      ..add(log);
    return log;
  }
}
