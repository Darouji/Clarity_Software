// lib/screens/admin/admin_dashboard_screen.dart
import 'dart:ui';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/screens/admin/admin_project_list_screen.dart';
import 'package:clarity_software/screens/admin/admin_appointments_screen.dart';
import 'package:clarity_software/screens/admin/admin_clients_screen.dart'; // Nueva importación
import 'package:clarity_software/widgets/dashboard_tile.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor: AppColors.appBarBackground.withValues(
                alpha: 0.8,
              ),
              elevation: 0,
              title: const Text(
                'Panel de Administración',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: const [GlobalAppBarMenu(currentScreen: AppScreen.admin)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido, Administrador',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Dashboard Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Bloque 1: Proyectos
                DashboardTile(
                  title: 'Proyectos',
                  icon: Icons.folder_open,
                  color: AppColors.cyberBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminProjectListScreen(),
                      ),
                    );
                  },
                ),
                // Bloque 2: Citas (Calendario de Reuniones)
                DashboardTile(
                  title: 'Citas',
                  icon: Icons.calendar_month,
                  color: AppColors.accentGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminAppointmentsScreen(),
                      ),
                    );
                  },
                ),
                // Bloque 3: Clientes (Acceso directo a la lista)
                DashboardTile(
                  title: 'Clientes',
                  icon: Icons.people_outline,
                  color: AppColors.accentPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminClientsScreen(),
                      ),
                    );
                  },
                ),
                // Bloque 4: Finanzas (Placeholder)
                DashboardTile(
                  title: 'Finanzas',
                  icon: Icons.attach_money,
                  color: AppColors.accentOrange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Módulo de Finanzas próximamente')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
