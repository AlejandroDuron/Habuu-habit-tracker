// pruebas del interruptor de verificación en Perfil > Seguridad y de que la
// preferencia se guarde en SharedPreferences

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habuu/data/datasources/verification_preferences.dart';
import 'package:habuu/presentation/providers/verification_settings_provider.dart';
import 'package:habuu/presentation/screens/profile/security_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_verification_preferences.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<VerificationSettingsProvider> openScreen(
    WidgetTester tester,
    FakeVerificationPreferences prefs,
  ) async {
    final settings = VerificationSettingsProvider(prefs);
    await settings.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: const MaterialApp(home: SecurityScreen()),
      ),
    );
    return settings;
  }

  testWidgets('quitar la verificación pide confirmación', (tester) async {
    final prefs = FakeVerificationPreferences(value: true);
    await openScreen(tester, prefs);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('¿Quitar la verificación?'), findsOneWidget);

    await tester.tap(find.text('Quitar'));
    await tester.pumpAndSettle();
    expect(prefs.value, isFalse);
  });

  testWidgets('si cancela, la verificación sigue activada', (tester) async {
    final prefs = FakeVerificationPreferences(value: true);
    await openScreen(tester, prefs);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(prefs.value, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('volver a activarla muestra el aviso de Google', (tester) async {
    final prefs = FakeVerificationPreferences(value: false);
    await openScreen(tester, prefs);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('¿Verificar tus fotos?'), findsOneWidget);

    await tester.tap(find.text('Verificar'));
    await tester.pumpAndSettle();
    expect(prefs.value, isTrue);
  });

  test(
    'SharedPrefsVerificationPreferences guarda y lee la preferencia',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = SharedPrefsVerificationPreferences();

      expect(await prefs.isEnabled(), isNull);
      await prefs.setEnabled(false);
      expect(await prefs.isEnabled(), isFalse);
    },
  );
}
