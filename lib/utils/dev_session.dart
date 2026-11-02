import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Solo en modo debug: inicia sesión con una cuenta de prueba para poder usar
/// el Home mientras el login no está conectado.
///
/// La cuenta se pasa al compilar, por ejemplo desde el archivo .env:
/// `flutter run --dart-define-from-file=.env`
/// con DEV_EMAIL y DEV_PASSWORD. Si no vienen, no hace nada.
Future<void> signInForDevelopment(SupabaseClient client) async {
  if (!kDebugMode) return;

  const email = String.fromEnvironment('DEV_EMAIL');
  const password = String.fromEnvironment('DEV_PASSWORD');
  if (email.isEmpty || password.isEmpty) return;

  // Supabase recuerda la sesión entre aperturas de la app. Si ya es la cuenta
  // de prueba no hace falta entrar otra vez; si es otra, se cambia.
  final current = client.auth.currentUser;
  if (current?.email?.toLowerCase() == email.toLowerCase()) return;

  try {
    if (current != null) await client.auth.signOut();
    await client.auth.signInWithPassword(email: email, password: password);
  } on AuthException catch (e) {
    debugPrint(
      'No se pudo iniciar la sesión de prueba (${e.statusCode}): ${e.message}',
    );
  }
}
