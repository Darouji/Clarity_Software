// lib/screens/admin/admin_dashboard_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/screens/admin/admin_appointments_screen.dart';
import 'package:clarity_software/screens/admin/client_editor_dialog.dart';
import 'package:clarity_software/screens/admin/admin_project_list_screen.dart';
import 'package:clarity_software/services/user_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final UserService _userService = UserService();

  void _navigateToClientProjects(ClientUser client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProjectListScreen(client: client),
      ),
    );
  }

  void _navigateToAppointments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminAppointmentsScreen()),
    );
  }

  void _showClientDialog([ClientUser? client]) async {
    final result = await showDialog<ClientUser>(
      context: context,
      builder: (context) => ClientEditorDialog(client: client),
    );
    if (result != null) {
      await _userService.saveUser(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double appBarHeight = 65.0;
    // Padding superior corregido
    final double topContentPadding =
        MediaQuery.of(context).padding.top + appBarHeight + 20;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: theme.appBarTheme.backgroundColor,
              child: SafeArea(
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment(0.0, 0.2),
                      child: Text(
                        'Panel de Control',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(1.0, 0.2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                            ),
                            tooltip: 'Solicitudes de Citas',
                            onPressed: _navigateToAppointments,
                          ),
                          const GlobalAppBarMenu(
                            currentScreen: AppScreen.admin,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<ClientUser>>(
        stream: _userService.getClientsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyberBlue),
            );
          }
          final clients = snapshot.data ?? [];

          if (clients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: AppColors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No hay clientes registrados.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16,
              topContentPadding,
              16,
              80,
            ), // Padding inferior para el FAB
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: () => _navigateToClientProjects(client),
                  child: NeonCard(
                    glowColor: AppColors.cyberBlue.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cyberBlue.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.cyberBlue),
                          ),
                          child: client.photoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    client.photoUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: AppColors.cyberBlue,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                client.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.grey,
                          ),
                          onPressed: () => _showClientDialog(client),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.cyberBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentMagenta,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
        onPressed: () => _showClientDialog(),
      ),
    );
  }
}
