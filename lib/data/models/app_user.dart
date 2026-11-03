/// Usuario con sesión iniciada. Así la app no depende del `User` de Supabase.
class AppUser {
  const AppUser({required this.id, required this.email, this.name});

  final String id;
  final String email;

  /// El que escribió al registrarse. Las cuentas viejas no lo tienen.
  final String? name;
}
