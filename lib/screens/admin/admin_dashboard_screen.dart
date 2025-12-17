import 'package:flutter/material.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/screens/admin/admin_appointments_screen.dart';
import 'package:clarity_software/screens/admin/admin_project_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: const Text('Panel de Administración',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.accentMagenta),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido, Admin',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- BLOQUE 1: CALENDARIO DE REUNIONES ---
            _buildAdminOptionBlock(
              context: context,
              title: "Calendario de Reuniones",
              subtitle: "Ver próximas citas y reagendar",
              icon: Icons.calendar_month,
              color: AppColors.cyberBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminAppointmentsScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            // --- BLOQUE 2: CLIENTES ---
            _buildAdminOptionBlock(
              context: context,
              title: "Gestión de Clientes",
              subtitle: "Ver lista de clientes y sus proyectos",
              icon: Icons.people,
              color: AppColors.accentGreen,
              onTap: () {
                // Navegar a la lista de proyectos (que actúa como lista de clientes)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminProjectListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOptionBlock({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)), // CORREGIDO
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1), // CORREGIDO
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2), // CORREGIDO
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14), // CORREGIDO
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.5),
                size: 16), // CORREGIDO
          ],
        ),
      ),
    );
  }
}
