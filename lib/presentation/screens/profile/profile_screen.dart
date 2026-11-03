import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/assets.dart';
import '../../../config/routes.dart';
import '../../../config/theme/tokens.dart';
import '../../models/profile/profile_menu_entry.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/profile/pond_alert_card.dart';
import '../../widgets/profile/pond_scroll_view.dart';
import '../../widgets/profile/profile_menu.dart';
import 'logout_confirm_screen.dart';
import 'profile_mock_data.dart';
import 'security_screen.dart';
import 'user_screen.dart';

/// Pestaña "Perfil": aviso de la ranita y menú de configuración.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onGoToPond});

  /// Lleva al Home; lo resuelve la barra inferior.
  final VoidCallback onGoToPond;

  // ── Navegación ────────────────────────────────────────────────────────────

  void _openUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const UserScreen(user: ProfileMockData.user),
      ),
    );
  }

  void _openSecurity(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SecurityScreen()));
  }

  /// La confirmación tapa la barra inferior, por eso va en el navigator raíz.
  void _confirmLogout(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (routeContext) => LogoutConfirmScreen(
          onConfirm: () {
            routeContext.read<AuthProvider>().logout();
            Navigator.of(routeContext)
                .pushNamedAndRemoveUntil(AppRoutes.landing, (_) => false);
          },
          onCancel: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PondScrollView(
      children: [
        Text(
          'Perfil',
          textAlign: TextAlign.center,
          style: HabuuText.h5ExtraBold.copyWith(color: HabuuColors.primary600),
        ),
        const SizedBox(height: 56),
        PondAlertCard(onGoToPond: onGoToPond),
        const SizedBox(height: 56),
        ProfileMenu(
          groups: [
            [
              ProfileMenuEntry(
                icon: ProfileAssets.user,
                label: 'Usuario',
                onTap: () => _openUser(context),
              ),
              const ProfileMenuEntry(
                icon: ProfileAssets.tools,
                label: 'Preferencias',
              ),
              ProfileMenuEntry(
                icon: ProfileAssets.shield,
                label: 'Seguridad',
                onTap: () => _openSecurity(context),
              ),
            ],
            [
              const ProfileMenuEntry(
                icon: ProfileAssets.help,
                label: 'Ayuda y soporte técnico',
              ),
              ProfileMenuEntry(
                icon: ProfileAssets.logOut,
                label: 'Cerrar sesión',
                isDestructive: true,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
