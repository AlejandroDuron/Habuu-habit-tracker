import '../../../config/assets.dart';
import '../../models/profile/user_profile.dart';

/// Datos de ejemplo del perfil mientras no vengan del backend.
abstract final class ProfileMockData {
  static const user = UserProfile(
    fullName: 'Paola Suaregg',
    email: 'paola@correo.com',
    phone: '+503 7123 4567',
    gender: 'Femenino',
    birthday: '12/05/02',
    avatarAsset: ProfileAssets.avatar,
  );
}
