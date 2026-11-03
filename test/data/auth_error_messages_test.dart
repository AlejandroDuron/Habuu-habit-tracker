// traducción de los errores de Supabase Auth: el usuario nunca debe ver el
// texto original en inglés

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/repositories/auth_error_messages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  AuthException apiError(String code, {String message = 'raw server text'}) =>
      AuthApiException(message, statusCode: '400', code: code);

  test('credenciales inválidas', () {
    expect(
      authErrorMessage(apiError('invalid_credentials')),
      invalidCredentialsAuthError,
    );
  });

  test('correo ya registrado, con cualquiera de los dos códigos', () {
    expect(
      authErrorMessage(apiError('user_already_exists')),
      emailTakenAuthError,
    );
    expect(authErrorMessage(apiError('email_exists')), emailTakenAuthError);
  });

  test('contraseña débil', () {
    expect(
      authErrorMessage(apiError('weak_password')),
      'La contraseña no cumple los requisitos.',
    );
  });

  test('correo sin confirmar', () {
    expect(
      authErrorMessage(apiError('email_not_confirmed')),
      contains('no está verificada'),
    );
  });

  test('código vencido o incorrecto', () {
    expect(
      authErrorMessage(apiError('otp_expired')),
      'Código incorrecto o vencido. Pide uno nuevo.',
    );
  });

  test('demasiados intentos', () {
    expect(
      authErrorMessage(apiError('over_request_rate_limit')),
      tooManyAttemptsAuthError,
    );
    expect(
      authErrorMessage(apiError('over_email_send_rate_limit')),
      'Espera un momento antes de pedir otro código.',
    );
  });

  test('un 429 sin código también cuenta como demasiados intentos', () {
    expect(
      authErrorMessage(const AuthException('Too many', statusCode: '429')),
      tooManyAttemptsAuthError,
    );
  });

  test('sin conexión: la petición no llegó y no hay código HTTP', () {
    expect(
      authErrorMessage(AuthRetryableFetchException(message: 'SocketException')),
      noConnectionAuthError,
    );
  });

  test('error del servidor (5xx) no se confunde con sin conexión', () {
    final message = authErrorMessage(
      AuthRetryableFetchException(message: 'Bad gateway', statusCode: '502'),
    );
    expect(message, isNot(noConnectionAuthError));
    expect(message, contains('no está disponible'));
  });

  test('errores viejos sin código se reconocen por el texto', () {
    expect(
      authErrorMessage(const AuthException('Invalid login credentials')),
      invalidCredentialsAuthError,
    );
  });

  test('un error desconocido da el mensaje genérico, no el texto crudo', () {
    final message = authErrorMessage(
      apiError('algo_nuevo', message: 'Database error saving new user'),
    );
    expect(message, genericAuthError);
    expect(message, isNot(contains('Database')));
  });

  test('un texto con "invalid" no se toma como código incorrecto', () {
    final message = authErrorMessage(
      const AuthException('Unable to validate email address: invalid format'),
    );
    expect(message, genericAuthError);
  });
}
