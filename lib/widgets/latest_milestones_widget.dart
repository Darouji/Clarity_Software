// lib/widgets/latest_milestones_widget.dart
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/global_timeline_screen.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class LatestMilestonesWidget extends StatelessWidget {
  final List<Project> projects;

  const LatestMilestonesWidget({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allMilestones = [];

    for (var project in projects) {
      if (project.status != 'Finalizado') {
        for (var milestone in project.milestones) {
          if (milestone.status != MilestoneStatus.completed) {
            allMilestones.add({
              'milestone': milestone,
              'project': project,
              'date': milestone.deadline,
            });
          }
        }
      }
    }

    allMilestones.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    final displayList = allMilestones.take(2).toList();

    return NeonCard(
      glowColor: AppColors.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Últimos Hitos',
                  style: TextStyle(
                      color: AppColors.accentPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Icon(Icons.flag_outlined,
                  color: AppColors.accentPurple, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: displayList.isEmpty
                ? const Align(
                    alignment: Alignment.topLeft,
                    child: Text('No tienes hitos pendientes.',
                        style: TextStyle(color: Colors.white38, fontSize: 13)))
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayList.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white10, height: 16),
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      final Milestone m = item['milestone'];
                      final Project p = item['project'];

                      return InkWell(
                        onTap: () {
                          // AQUÍ ESTÁ LA CLAVE: Enviamos el título del hito para que se abra solo
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProjectDetailsScreen(
                                    project: p,
                                    highlightMilestoneTitle: m.title)),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                                m.status == MilestoneStatus.completed
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: m.status == MilestoneStatus.completed
                                    ? AppColors.accentGreen
                                    : Colors.white54,
                                size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(m.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(p.name,
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                ])),
                            Text('${m.deadline.day}/${m.deadline.month}',
                                style: const TextStyle(
                                    color: AppColors.accentPurple,
                                    fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const GlobalTimelineScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.accentPurple.withValues(alpha: 0.3)),
                      foregroundColor: AppColors.accentPurple,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      visualDensity: VisualDensity.compact),
                  child: const Text('Ver Todos los Hitos'))),
        ],
      ),
    );
  }
}
