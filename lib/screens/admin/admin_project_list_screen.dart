// lib/screens/admin/admin_project_list_screen.dart
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/admin/project_editor_screen.dart'; // Asegúrate de tener esta pantalla creada o quita la navegación si no
import 'package:clarity_software/services/mock_api_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AdminProjectListScreen extends StatefulWidget {
  final ClientUser client;

  const AdminProjectListScreen({super.key, required this.client});

  @override
  State<AdminProjectListScreen> createState() => _AdminProjectListScreenState();
}

class _AdminProjectListScreenState extends State<AdminProjectListScreen> {
  final MockApiService _apiService = MockApiService();
  late List<Project> _projects;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    setState(() {
      _projects = _apiService.getProjectsForClient(widget.client.id);
    });
  }

  Future<void> _deleteProject(String projectId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Eliminar este proyecto?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.deleteProject(projectId);

      // --- CORRECCIÓN: Verificar si el widget sigue montado ---
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Proyecto eliminado')));
      _loadProjects();
    }
  }

  void _editProject(Project? project) async {
    // Navegar al editor (asegúrate de que ProjectEditorScreen exista)
    /* final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectEditorScreen(
          project: project,
          clientId: widget.client.id,
        ),
      ),
    );
    if (result == true) {
      _loadProjects();
    }
    */
    // Por ahora, solo recargamos para evitar errores si no tienes el archivo del editor
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Proyectos: ${widget.client.name}')),
      body: _projects.isEmpty
          ? const Center(child: Text('Sin proyectos asignados'))
          : ListView.builder(
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return ListTile(
                  title: Text(
                    project.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    project.status,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.cyberBlue,
                        ),
                        onPressed: () => _editProject(project),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteProject(project.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentMagenta,
        child: const Icon(Icons.add),
        onPressed: () => _editProject(null),
      ),
    );
  }
}
