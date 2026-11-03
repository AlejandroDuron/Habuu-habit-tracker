import 'package:supabase_flutter/supabase_flutter.dart';

const genericAuthError = 'Algo salió mal. Inténtalo de nuevo.';
const noConnectionAuthError =
    'No hay conexión. Revisa tu internet e inténtalo de nuevo.';
const invalidCredentialsAuthError = 'Correo o contraseña incorrectos.';
const emailTakenAuthError = 'Este correo ya está registrado. Inicia sesión.';
const tooManyAttemptsAuthError =
    'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';

/// Traduce un error de Supabase Auth a un mensaje para el usuario.
/// Nunca devuelve el texto original del servidor.
String authErrorMessage(AuthException e) {
  if (e is AuthRetryableFetchException) {
    // Sin código HTTP es que la petición ni siquiera llegó.
    return e.statusCode == null
        ? noConnectionAuthError
        : 'El servicio no está disponible. Inténtalo más tarde.';
  }

  switch (e.code) {
    case 'invalid_credentials':
      return invalidCredentialsAuthError;
    case 'email_not_confirmed':
      return 'Tu cuenta aún no está verificada. Crea la cuenta de nuevo '
          'para recibir otro código.';
    case 'user_already_exists':
    case 'email_exists':
      return emailTakenAuthError;
    case 'weak_password':
      return 'La contraseña no cumple los requisitos.';
    case 'same_password':
      return 'La nueva contraseña debe ser distinta a la anterior.';
    case 'otp_expired':
      return 'Código incorrecto o vencido. Pide uno nuevo.';
    case 'over_email_send_rate_limit':
      return 'Espera un momento antes de pedir otro código.';
    case 'over_request_rate_limit':
      return tooManyAttemptsAuthError;
    case 'email_address_invalid':
      return 'Ingresa un correo válido.';
    case 'signup_disabled':
      return 'El registro de cuentas está desactivado.';
    case 'session_not_found':
    case 'session_expired':
    case 'refresh_token_not_found':
      return 'Tu sesión expiró. Inicia sesión de nuevo.';
  }

  // Algunos errores llegan sin código, solo con el texto en inglés.
  final message = e.message.toLowerCase();
  if (message.contains('invalid login credentials')) {
    return invalidCredentialsAuthError;
  }
  if (message.contains('token has expired or is invalid')) {
    return 'Código incorrecto o vencido. Pide uno nuevo.';
  }
  if (e.statusCode == '429') return tooManyAttemptsAuthError;

  return genericAuthError;
}
