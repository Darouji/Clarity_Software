// lib/widgets/project_list_view.dart
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProjectListView extends StatelessWidget {
  final Project project;

  const ProjectListView({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: project.milestones.length,
      itemBuilder: (context, index) {
        final milestone = project.milestones[index];

        Color iconColor;
        IconData iconData;

        if (milestone.status == MilestoneStatus.completed) {
          iconColor = AppColors.accentGreen;
          iconData = Icons.check_circle_outline;
        } else if (milestone.status == MilestoneStatus.inProgress) {
          iconColor = AppColors.cyberBlue;
          iconData = Icons.timelapse;
        } else {
          iconColor = AppColors.grey;
          iconData = Icons.radio_button_unchecked;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            title: Text(
              milestone.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  milestone.fase.toString().split('.').last,
                  style: TextStyle(color: iconColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: milestone.progress,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(iconColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 14,
            ),
          ),
        );
      },
    );
  }
}
