// lib/screens/admin/admin_dashboard_screen.dart
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/screens/admin/client_editor_dialog.dart';
import 'package:clarity_software/screens/admin/admin_project_list_screen.dart';
import 'package:clarity_software/services/mock_api_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final MockApiService _apiService = MockApiService();
  late List<ClientUser> _clients;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() {
    setState(() {
      _clients = _apiService.getClients();
    });
  }

  // Navega a la lista de proyectos de un cliente
  void _navigateToClientProjects(ClientUser client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProjectListScreen(client: client),
      ),
    );
  }

  // Muestra el popup para crear o editar un cliente
  void _showClientDialog([ClientUser? client]) async {
    final result = await showDialog<ClientUser>(
      context: context,
      builder: (context) => ClientEditorDialog(client: client),
    );

    if (result != null) {
      await _apiService.saveClient(result);
      _loadClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Clientes'),
        actions: const [GlobalAppBarMenu(currentScreen: AppScreen.admin)],
      ),
      body: ListView.builder(
        itemCount: _clients.length,
        itemBuilder: (context, index) {
          final client = _clients[index];
          return ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: AppColors.cyberBlue,
            ),
            title: Text(client.name),
            subtitle: Text(client.email),
            trailing: IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.grey,
                size: 20,
              ),
              onPressed: () => _showClientDialog(client),
            ),
            onTap: () => _navigateToClientProjects(client),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentMagenta,
        child: const Icon(Icons.person_add_alt_1),
        onPressed: () => _showClientDialog(),
      ),
    );
  }
}
