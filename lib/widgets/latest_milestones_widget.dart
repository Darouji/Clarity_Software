// lib/widgets/latest_milestones_widget.dart
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/services/view_status_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LatestMilestonesWidget extends StatelessWidget {
  final List<Project> projects;

  const LatestMilestonesWidget({super.key, required this.projects});

  void _navigateToMilestone(
    BuildContext context,
    Project project,
    String milestoneTitle,
  ) {
    // Marcamos el proyecto como visto
    final ViewStatusService viewService = ViewStatusService();
    viewService.markAsViewed(project.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(
          project: project,
          highlightMilestoneTitle:
              milestoneTitle, // Esto hará que el Kanban haga scroll
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Obtener todos los hitos pendientes o recientes
    final allMilestones = projects.expand((p) {
      return p.milestones
          .where(
            (m) => m.status.toString() != 'MilestoneStatus.completed',
          ) // Solo pendientes
          .map((m) => MapEntry(m, p)); // Guardamos par (Hito, Proyecto)
    }).toList();

    // 2. Ordenar por fecha de vencimiento (más urgente primero)
    allMilestones.sort((a, b) => a.key.deadline.compareTo(b.key.deadline));

    // 3. Tomar los primeros 5 (Lista expandible verticalmente)
    final recent = allMilestones.take(5).toList();

    if (recent.isEmpty) return const SizedBox();

    return NeonCard(
      glowColor: AppColors.accentOrange.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag, color: AppColors.accentOrange, size: 20),
              SizedBox(width: 8),
              Text(
                'Últimos Hitos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recent.map((entry) {
            final m = entry.key;
            final project = entry.value;
            final daysLeft = m.deadline.difference(DateTime.now()).inDays;

            Color timeColor = Colors.white70;
            String timeText =
                '${DateFormat('dd/MM').format(m.deadline)} ($daysLeft días)';

            if (daysLeft < 0) {
              timeColor = AppColors.accentRed;
              timeText = 'Vencido hace ${daysLeft.abs()} días';
            } else if (daysLeft <= 3) {
              timeColor = AppColors.accentOrange;
              timeText = 'Vence en $daysLeft días';
            }

            return InkWell(
              onTap: () => _navigateToMilestone(context, project, m.title),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: timeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${project.name} • $timeText',
                            style: TextStyle(
                              color: timeColor.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white24,
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
