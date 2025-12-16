// lib/widgets/project_timeline_view.dart
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class ProjectTimelineView extends StatelessWidget {
  final Project project;

  const ProjectTimelineView({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final milestones = project.milestones;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final isLast = index == milestones.length - 1;

        Color statusColor;
        if (milestone.status == MilestoneStatus.completed) {
          statusColor = AppColors.accentGreen;
        } else if (milestone.status == MilestoneStatus.inProgress) {
          statusColor = AppColors.cyberBlue;
        } else {
          statusColor = AppColors.grey;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna de la línea de tiempo
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: statusColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),

              // Contenido de la tarjeta
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: NeonCard(
                    glowColor: statusColor.withValues(alpha: 0.3),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                milestone.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (milestone.status == MilestoneStatus.completed)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.accentGreen,
                                size: 18,
                              ),
                          ],
                        ),

                        // CORRECCIÓN: Eliminada la línea que pedía 'description'
                        // y reemplazada por un espaciador simple
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                milestone.fase
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(milestone.progress * 100).toInt()}%',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
