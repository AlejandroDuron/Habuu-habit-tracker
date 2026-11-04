import '../datasources/profile_data_source.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._dataSource);

  final ProfileDataSource _dataSource;

  Future<UserProfile> getProfile() => _dataSource.getProfile();

  Future<UserProfile> saveProfile(UserProfile profile) =>
      _dataSource.saveProfile(profile);
}
