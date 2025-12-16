// lib/widgets/global_menu.dart
import 'package:clarity_software/screens/client/notifications_screen.dart';
import 'package:clarity_software/screens/login_screen.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/services/auth_service.dart';

// Enum para identificar la pantalla actual
enum AppScreen { overview, timeline, projectDetails, notifications, admin }

class GlobalAppBarMenu extends StatelessWidget {
  final AppScreen currentScreen;

  const GlobalAppBarMenu({super.key, required this.currentScreen});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        onSelected: (value) {
          switch (value) {
            case 'logout':
              AuthService().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
              break;
            case 'notifications':
            // Ahora la opción de Admin también lleva aquí
            case 'admin_notifications':
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          List<PopupMenuEntry<String>> menuItems = [];

          // 1. Notificaciones (Común para Admin y Cliente)
          if (currentScreen != AppScreen.notifications) {
            final isNotifAdmin = currentScreen == AppScreen.admin;
            menuItems.add(
              PopupMenuItem<String>(
                value: isNotifAdmin ? 'admin_notifications' : 'notifications',
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: textTheme.bodyLarge?.color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Notificaciones'),
                  ],
                ),
              ),
            );
          }

          // 2. Separador
          menuItems.add(const PopupMenuDivider());

          // 3. Cerrar Sesión (Siempre visible)
          menuItems.add(
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.accentRed, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: AppColors.accentRed),
                  ),
                ],
              ),
            ),
          );

          return menuItems;
        },
      ),
    );
  }
}
