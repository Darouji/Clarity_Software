// lib/widgets/global_menu.dart
import 'package:clarity_software/screens/client/global_timeline_screen.dart';
import 'package:clarity_software/screens/client/notifications_screen.dart';
import 'package:clarity_software/screens/client/overview_screen.dart';
import 'package:clarity_software/screens/login_screen.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

// --- INICIO DE CAMBIOS ---
// Importamos el nuevo servicio de Auth
import 'package:clarity_software/services/auth_service.dart';
// --- FIN DE CAMBIOS ---

// Enum para identificar la pantalla actual y mostrar/ocultar opciones
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
        onSelected: (value) {
          // Lógica de navegación centralizada
          switch (value) {
            case 'logout':
              // --- INICIO DE CAMBIOS ---
              // Limpiamos el estado de autenticación
              AuthService().signOut();
              // --- FIN DE CAMBIOS ---
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
              break;
            case 'notifications':
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
              break;
            case 'view_timeline':
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const GlobalTimelineScreen(),
                ),
              );
              break;
            case 'view_dashboard':
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const OverviewScreen()),
              );
              break;
            case 'admin_notifications':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificaciones de Admin (próximamente).'),
                  backgroundColor: AppColors.cyberBlue,
                ),
              );
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          // Lista de widgets para el menú
          List<PopupMenuEntry<String>> menuItems = [];

          // --- Lógica condicional para Admin ---
          if (currentScreen == AppScreen.admin) {
            menuItems.add(
              PopupMenuItem<String>(
                value: 'admin_notifications',
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: 8),
                    const Text('Notificaciones'),
                  ],
                ),
              ),
            );
          }
          // --- Lógica condicional para Cliente ---
          else {
            // 1. Añadir "Notificaciones" (si no estamos en esa pantalla)
            if (currentScreen != AppScreen.notifications) {
              menuItems.add(
                PopupMenuItem<String>(
                  value: 'notifications',
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: textTheme.bodyLarge?.color,
                      ),
                      const SizedBox(width: 8),
                      const Text('Notificaciones'),
                    ],
                  ),
                ),
              );
            }

            // 2. Añadir "Cambiar Vista"
            if (currentScreen == AppScreen.overview ||
                currentScreen == AppScreen.projectDetails) {
              // Si estamos en Dashboard o Detalles, mostramos "Ir a Timeline"
              menuItems.add(
                PopupMenuItem<String>(
                  value: 'view_timeline',
                  child: Row(
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        color: textTheme.bodyLarge?.color,
                      ),
                      const SizedBox(width: 8),
                      const Text('Cambiar a Vista Timeline'),
                    ],
                  ),
                ),
              );
            } else if (currentScreen == AppScreen.timeline ||
                currentScreen == AppScreen.notifications) {
              // Si estamos en Timeline o Notificaciones, mostramos "Ir a Dashboard"
              menuItems.add(
                PopupMenuItem<String>(
                  value: 'view_dashboard',
                  child: Row(
                    children: [
                      Icon(
                        Icons.dashboard_outlined,
                        color: textTheme.bodyLarge?.color,
                      ),
                      const SizedBox(width: 8),
                      const Text('Cambiar a Vista Dashboard'),
                    ],
                  ),
                ),
              );
            }
          }

          // 3. Añadir Separador y "Cerrar Sesión" (siempre)
          menuItems.add(const PopupMenuDivider());
          menuItems.add(
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: textTheme.bodyLarge?.color),
                  const SizedBox(width: 8),
                  const Text('Cerrar Sesión'),
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
