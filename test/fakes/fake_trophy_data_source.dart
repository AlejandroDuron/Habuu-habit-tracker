// sin trofeos, solo para poder armar el TrophiesProvider que pide el Home

import 'package:habuu/data/datasources/trophy_data_source.dart';
import 'package:habuu/data/models/trophy.dart';

class FakeTrophyDataSource implements TrophyDataSource {
  @override
  Future<List<Trophy>> getAllTrophies() async => [];

  @override
  Future<List<EarnedTrophy>> getEarnedTrophies() async => [];

  @override
  Future<EarnedTrophy?> awardTrophy(String trophyId) async => null;
}
