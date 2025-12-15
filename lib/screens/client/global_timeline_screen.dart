// lib/screens/client/global_timeline_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/services/mock_api_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/widgets/global_menu.dart';

// --- INICIO DE CAMBIOS ---
// Importamos el servicio de Auth
import 'package:clarity_software/services/auth_service.dart';
// --- FIN DE CAMBIOS ---

class _TimelineEntry {
  final Project project;
  final Milestone milestone;
  _TimelineEntry(this.project, this.milestone);
}

class GlobalTimelineScreen extends StatelessWidget {
  const GlobalTimelineScreen({super.key});

  IconData _getStatusIcon(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return Icons.check_circle_outline;
      case MilestoneStatus.inProgress:
        return Icons.donut_large;
      case MilestoneStatus.pending:
        return Icons.circle_outlined;
    }
  }

  Color _getStatusColor(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return AppColors.accentGreen;
      case MilestoneStatus.inProgress:
        return AppColors.cyberBlue;
      case MilestoneStatus.pending:
        return AppColors.accentRed;
    }
  }

  String _formatDeadline(DateTime deadline) {
    return "${deadline.day.toString().padLeft(2, '0')}/${deadline.month.toString().padLeft(2, '0')}/${deadline.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTextStyle = theme.appBarTheme.titleTextStyle;
    const double appBarHeight = 65.0;

    // --- Lógica de datos (ACTUALIZADA) ---
    final MockApiService apiService = MockApiService();
    final AuthService authService = AuthService();
    final currentUser = authService.currentUser;

    // 1. Obtenemos solo los proyectos del cliente actual
    final List<Project> projects = (currentUser == null)
        ? []
        : apiService.getProjectsForClient(currentUser.id);

    // 2. Aplanamos todos los hitos de ESOS proyectos
    final List<_TimelineEntry> allEntries = [];
    for (final project in projects) {
      for (final milestone in project.milestones) {
        allEntries.add(_TimelineEntry(project, milestone));
      }
    }

    // 3. Ordenamos
    allEntries.sort(
      (a, b) => a.milestone.deadline.compareTo(b.milestone.deadline),
    );
    // --- Fin de la lógica de datos ---

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
                      alignment: const Alignment(0.0, 0.2),
                      child: Text(
                        'Timeline de Actividad',
                        style: appBarTextStyle,
                      ),
                    ),
                    const Align(
                      alignment: Alignment(1.0, 0.2),
                      child: GlobalAppBarMenu(
                        currentScreen: AppScreen.timeline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          // --- INICIO DE CAMBIO: Manejar si no hay hitos ---
          (allEntries.isEmpty)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No tienes hitos programados en tus proyectos.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount:
                  allEntries.length + 1, // +1 para el SizedBox del AppBar
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SizedBox(height: appBarHeight + 30.0);
                }
                final entry = allEntries[index - 1];
                final milestone = entry.milestone;
                final project = entry.project;

                final statusColor = _getStatusColor(milestone.status);
                final statusIcon = _getStatusIcon(milestone.status);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectDetailsScreen(project: project),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15.0),
                    child: NeonCard(
                      glowColor: statusColor.withAlpha(150),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  milestone.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Proyecto: ${project.name}",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Vence: ${_formatDeadline(milestone.deadline)}",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      // --- FIN DE CAMBIO ---
    );
  }
}
