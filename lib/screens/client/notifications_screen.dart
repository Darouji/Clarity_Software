// lib/screens/client/notifications_screen.dart
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

// --- INICIO DE CAMBIOS ---
// Importamos el nuevo widget
import 'package:clarity_software/widgets/global_menu.dart';
// Ya no necesitamos las otras importaciones de navegación
// --- FIN DE CAMBIOS ---

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _emailNotifications = true;
  bool _weeklySummary = true;
  bool _milestoneAlerts = true;

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones y Preferencias'),
        // --- INICIO DE CAMBIOS: Menú de Acciones ---
        actions: const [
          GlobalAppBarMenu(currentScreen: AppScreen.notifications),
        ],
        // --- FIN DE CAMBIOS ---
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NeonCard(
              glowColor: AppColors.cyberBlue.withValues(alpha: 0.5),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: _buildIcon(
                      Icons.email_outlined,
                      AppColors.cyberBlue, // Azul
                    ),
                    title: const Text('Actualizaciones por Email'),
                    value: _emailNotifications,
                    onChanged: (bool value) =>
                        setState(() => _emailNotifications = value),
                    activeThumbColor: AppColors.cyberBlue, // Color del switch
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: _buildIcon(
                      Icons.calendar_today_outlined,
                      AppColors.accentMagenta, // Magenta
                    ),
                    title: const Text('Resumen semanal'),
                    value: _weeklySummary,
                    onChanged: (bool value) =>
                        setState(() => _weeklySummary = value),
                    activeThumbColor:
                        AppColors.accentMagenta, // Color del switch
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: _buildIcon(
                      Icons.flag_outlined,
                      AppColors.accentGreen, // Verde
                    ),
                    title: const Text('Hitos completados'),
                    value: _milestoneAlerts,
                    onChanged: (bool value) =>
                        setState(() => _milestoneAlerts = value),
                    activeThumbColor: AppColors.accentGreen, // Color del switch
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentMagenta, // Magenta
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preferencias guardadas.'),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              },
              child: const Text('Guardar Preferencias'),
            ),
          ],
        ),
      ),
    );
  }
}
