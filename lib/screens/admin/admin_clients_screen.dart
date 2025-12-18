// lib/screens/admin/admin_clients_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/screens/admin/client_details_screen.dart';
import 'package:clarity_software/services/user_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class AdminClientsScreen extends StatelessWidget {
  const AdminClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor:
                  AppColors.appBarBackground.withValues(alpha: 0.8),
              elevation: 0,
              leading: const BackButton(color: Colors.white),
              title: const Text(
                'Clientes',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: const [GlobalAppBarMenu(currentScreen: AppScreen.admin)],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<ClientUser>>(
        stream: userService.getClientsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyberBlue),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar clientes',
                style: TextStyle(color: AppColors.accentRed),
              ),
            );
          }

          final clients = snapshot.data ?? [];

          if (clients.isEmpty) {
            return const Center(
              child: Text(
                'No hay clientes registrados.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeonCard(
                  glowColor:
                      AppColors.cyberBlue, // CORREGIDO: Argumento requerido
                  onTap: () {
                    // CORREGIDO: Argumento ahora soportado
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClientDetailsScreen(client: client),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.cyberBlue.withValues(alpha: 0.2),
                      child: Text(
                        client.displayName.isNotEmpty
                            ? client.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: AppColors.cyberBlue),
                      ),
                    ),
                    title: Text(
                      client.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      client.email,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white54, size: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
