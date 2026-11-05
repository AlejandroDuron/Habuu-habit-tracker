/// Usuario con sesión iniciada
class AppUser {
  const AppUser({required this.id, required this.email, this.name});

  final String id;
  final String email;

  /// El que escribió al registrarse. Las cuentas viejas no lo tienen.
  final String? name;
}
