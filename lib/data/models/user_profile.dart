import '../../utils/dates.dart';

enum Gender {
  female('female', 'Femenino'),
  male('male', 'Masculino'),
  other('other', 'Otro'),
  preferNotSay('prefer_not_say', 'Prefiero no decirlo');

  const Gender(this.key, this.label);

  final String key;
  final String label;

  static Gender? fromKey(Object? value) {
    for (final gender in values) {
      if (gender.key == value) return gender;
    }
    return null;
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.fullName = '',
    this.phone,
    this.gender,
    this.birthday,
  });

  final String id;
  final String email;

  /// Vacío en las cuentas que no lo tienen.
  final String fullName;
  final String? phone;
  final Gender? gender;
  final DateTime? birthday;

  // 'name' es la misma clave que manda el registro.
  static const _nameKey = 'name';
  static const _phoneKey = 'phone';
  static const _genderKey = 'gender';
  static const _birthdayKey = 'birthday';

  /// Los metadatos no tienen esquema, así que un valor que no es del tipo
  /// esperado se ignora.
  factory UserProfile.fromMetadata({
    required String id,
    required String email,
    required Map<String, dynamic>? metadata,
  }) {
    final data = metadata ?? const {};
    final name = data[_nameKey];
    final phone = data[_phoneKey];
    final birthday = data[_birthdayKey];

    return UserProfile(
      id: id,
      email: email,
      fullName: name is String ? name.trim() : '',
      phone: phone is String && phone.trim().isNotEmpty ? phone.trim() : null,
      gender: Gender.fromKey(data[_genderKey]),
      birthday: birthday is String ? DateTime.tryParse(birthday) : null,
    );
  }

  /// Supabase mezcla estas claves con las que ya tenga la cuenta; las
  /// demás no se tocan.
  Map<String, dynamic> toMetadata() {
    final birthday = this.birthday;
    return {
      _nameKey: fullName,
      _phoneKey: phone,
      _genderKey: gender?.key,
      _birthdayKey: birthday == null ? null : isoDate(birthday),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.id == id &&
      other.email == email &&
      other.fullName == fullName &&
      other.phone == phone &&
      other.gender == gender &&
      other.birthday == birthday;

  @override
  int get hashCode => Object.hash(id, email, fullName, phone, gender, birthday);
}
