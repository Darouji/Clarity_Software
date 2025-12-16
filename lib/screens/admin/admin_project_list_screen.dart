// lib/screens/admin/admin_project_list_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/admin/project_editor_screen.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/services/project_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/info_block.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class AdminProjectListScreen extends StatefulWidget {
  final ClientUser client;

  const AdminProjectListScreen({super.key, required this.client});

  @override
  State<AdminProjectListScreen> createState() => _AdminProjectListScreenState();
}

class _AdminProjectListScreenState extends State<AdminProjectListScreen> {
  final ProjectService _projectService = ProjectService();

  Future<void> _deleteProject(String projectId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Eliminar este proyecto permanentemente?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _projectService.deleteProject(projectId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proyecto eliminado'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  void _editProject(Project? project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProjectEditorScreen(project: project, clientId: widget.client.id),
      ),
    );
  }

  void _viewProjectDetails(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(project: project),
      ),
    );
  }

  Color _getProjectColor(double progress) {
    if (progress == 0.0) return AppColors.accentMagenta;
    if (progress < 0.41) return AppColors.accentOrange;
    if (progress < 1.0) return AppColors.cyberBlue;
    return AppColors.accentGreen;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double appBarHeight = 65.0;
    final double topPadding =
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
                    Align(
                      alignment: const Alignment(-1.0, 0.2),
                      child: BackButton(color: theme.iconTheme.color),
                    ),
                    Align(
                      alignment: const Alignment(0.0, 0.2),
                      child: Text(
                        widget.client.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment(1.0, 0.2),
                      child: GlobalAppBarMenu(currentScreen: AppScreen.admin),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Project>>(
        stream: _projectService.getProjectsStream(widget.client.id, 'client'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyberBlue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.accentRed),
              ),
            );
          }

          final projects = snapshot.data ?? [];

          if (projects.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 60,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Este cliente no tiene proyectos.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, 80.0),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final glowColor = _getProjectColor(project.overallProgress);

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: GestureDetector(
                  onTap: () => _viewProjectDetails(project),
                  child: NeonCard(
                    glowColor: glowColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: AppColors.cyberBlue,
                                  tooltip: 'Editar Proyecto',
                                  onPressed: () => _editProject(project),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: AppColors.accentRed,
                                  tooltip: 'Eliminar Proyecto',
                                  onPressed: () => _deleteProject(project.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: LinearProgressIndicator(
                            value: project.overallProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.black.withValues(
                              alpha: 0.5,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              glowColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                                childAspectRatio: 2.5,
                              ),
                          children: [
                            InfoBlock(
                              icon: Icons.flag_outlined,
                              label: 'ESTADO',
                              value: project.status,
                              glowColor: AppColors.neonYellow,
                            ),
                            InfoBlock(
                              icon: Icons.attach_money_outlined,
                              label: 'PRESUPUESTO',
                              value: '\$${project.budget}',
                              glowColor: AppColors.neonMoneyGreen,
                            ),
                            InfoBlock(
                              icon: Icons.people_outline,
                              label: 'EQUIPO',
                              value: '${project.team.length}',
                              glowColor: AppColors.neonPink,
                            ),
                            InfoBlock(
                              icon: Icons.code_outlined,
                              label: 'TECH',
                              value: '${project.technologies.length}',
                              glowColor: AppColors.cyberBlue,
                            ),
                          ],
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
        onPressed: () => _editProject(null),
        tooltip: 'Crear Nuevo Proyecto',
        // CORRECCIÓN: 'child' ahora es el último argumento
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
