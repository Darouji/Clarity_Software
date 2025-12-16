// lib/screens/client/notifications_screen.dart
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/widgets/global_menu.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AuthService _authService = AuthService();

  bool _chatNotifications = true;
  bool _emailNotifications = true;
  bool _fileNotifications = true;

  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    // Determinamos si es Admin para adaptar los textos
    final user = _authService.currentUser;
    _isAdmin = user?.isAdmin ?? false;
  }

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
        title: Text(_isAdmin ? 'Configuración Admin' : 'Notificaciones'),
        actions: const [
          GlobalAppBarMenu(currentScreen: AppScreen.notifications),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NeonCard(
              glowColor: AppColors.cyberBlue.withValues(alpha: 0.5),
              child: Column(
                children: [
                  // OPCIÓN 1: CHAT / MENSAJES
                  SwitchListTile(
                    secondary: _buildIcon(
                      Icons.chat_bubble_outline,
                      AppColors.cyberBlue,
                    ),
                    title: Text(
                      _isAdmin
                          ? 'Mensajes de Clientes'
                          : 'Nuevos mensajes de chat',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _isAdmin
                          ? 'Avisos de chat y firmas pendientes'
                          : 'Respuestas de soporte y firmas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    value: _chatNotifications,
                    onChanged: (bool value) =>
                        setState(() => _chatNotifications = value),
                    activeThumbColor: AppColors.cyberBlue,
                  ),
                  const Divider(),

                  // OPCIÓN 2: EMAIL
                  SwitchListTile(
                    secondary: _buildIcon(
                      Icons.email_outlined,
                      AppColors.accentMagenta,
                    ),
                    title: const Text(
                      'Notificaciones por Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Alertas importantes del sistema',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    value: _emailNotifications,
                    onChanged: (bool value) =>
                        setState(() => _emailNotifications = value),
                    activeThumbColor: AppColors.accentMagenta,
                  ),
                  const Divider(),

                  // OPCIÓN 3: ARCHIVOS
                  SwitchListTile(
                    secondary: _buildIcon(
                      Icons.folder_open,
                      AppColors.accentGreen,
                    ),
                    title: Text(
                      _isAdmin ? 'Archivos de Clientes' : 'Archivos subidos',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _isAdmin
                          ? 'Avisos cuando un cliente sube documentos'
                          : 'Confirmación de subida exitosa',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    value: _fileNotifications,
                    onChanged: (bool value) =>
                        setState(() => _fileNotifications = value),
                    activeThumbColor: AppColors.accentGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentMagenta,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
