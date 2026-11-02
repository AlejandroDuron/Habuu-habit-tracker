/// Datos personales que se muestran en la pantalla de Usuario.
class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthday,
    required this.avatarAsset,
  });

  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String birthday;
  final String avatarAsset;
}
