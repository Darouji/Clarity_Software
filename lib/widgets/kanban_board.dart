// lib/widgets/kanban_board.dart
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/kanban_column.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/models/feedback_message.dart';
import 'package:clarity_software/services/feedback_notification_service.dart';
import 'package:clarity_software/screens/shared/chat_screen.dart';

class _KanbanMilestoneCard extends StatefulWidget {
  final Project project;
  final Milestone milestone;
  final Color glowColor;
  final String? highlightMilestoneTitle;

  const _KanbanMilestoneCard(
      {required this.project,
      required this.milestone,
      required this.glowColor,
      this.highlightMilestoneTitle});

  @override
  State<_KanbanMilestoneCard> createState() => _KanbanMilestoneCardState();
}

class _KanbanMilestoneCardState extends State<_KanbanMilestoneCard> {
  final FeedbackNotificationService _feedbackService =
      FeedbackNotificationService();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // AUTO-EXPANDIR SI ES EL HITO SELECCIONADO
    if (widget.highlightMilestoneTitle == widget.milestone.title) {
      _isExpanded = true;
      _markAsRead();
    }
  }

  void _markAsRead() {
    _feedbackService.markMilestoneFeedbackAsRead(
        widget.project.id, widget.milestone.title);
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) _markAsRead();
    });
  }

  void _openChatWithContext(bool isConform) {
    // CORRECCIÓN: Chat por CLIENTE, no por Proyecto. Título limpio.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          clientId:
              widget.project.clientId, // ID del cliente dueño del proyecto
          title: "Chat",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color progressColor;
    if (widget.milestone.status == MilestoneStatus.completed) {
      progressColor = AppColors.accentGreen;
    } else if (widget.milestone.status == MilestoneStatus.inProgress) {
      progressColor = (widget.milestone.progress >= 0.7)
          ? AppColors.cyberBlue
          : AppColors.accentOrange;
    } else {
      progressColor = AppColors.accentRed;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: NeonCard(
        glowColor: widget.glowColor
            .withValues(alpha: 0.15), // Ajuste de opacidad moderna
        padding: const EdgeInsets.all(12.0),
        child: InkWell(
          onTap: _toggleExpand,
          child: StreamBuilder<List<FeedbackMessage>>(
            stream: _feedbackService.getFeedbackStream(
                widget.project.id, widget.milestone.title),
            builder: (context, snapshot) {
              final feedbackHistory = snapshot.data ?? [];
              final int unreadCount = feedbackHistory
                  .where((f) => !f.isRead && f.author != 'Cliente')
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(widget.milestone.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold))),
                      if (unreadCount > 0 && !_isExpanded)
                        Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: AppColors.accentRed,
                                shape: BoxShape.circle),
                            child: Text(unreadCount.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold))),
                      Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.milestone.status.toString().split('.').last,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: progressColor)),
                      Text(
                          '${(widget.milestone.progress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: progressColor,
                                  fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: LinearProgressIndicator(
                          value: widget.milestone.progress,
                          minHeight: 6,
                          backgroundColor: progressColor.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor))),
                  if (_isExpanded)
                    _buildFeedbackSection(context, feedbackHistory),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
      BuildContext context, List<FeedbackMessage> feedbackHistory) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(color: AppColors.grey),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.cardBlack,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () => _openChatWithContext(true),
                  child: const Text('CONFORME',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () => _openChatWithContext(false),
                  child: const Text('NO CONFORME',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
        ]),
        if (feedbackHistory.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(color: AppColors.grey),
          const SizedBox(height: 8),
          const Text('Historial de Feedback:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ...feedbackHistory.map((msg) => _buildHistoryTile(msg)),
        ],
      ]),
    );
  }

  Widget _buildHistoryTile(FeedbackMessage msg) {
    final bool isApproval = msg.type == FeedbackType.approval;
    final Color color =
        isApproval ? AppColors.accentGreen : AppColors.accentRed;
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(isApproval ? Icons.check_circle : Icons.error_outline,
              color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    '${msg.author} - ${msg.timestamp.day}/${msg.timestamp.month}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                Text(msg.message, style: const TextStyle(fontSize: 13))
              ]))
        ]));
  }
}

class KanbanBoard extends StatelessWidget {
  const KanbanBoard(
      {super.key,
      required this.project,
      this.controller,
      this.highlightMilestoneTitle});
  final Project project;
  final PageController? controller;
  final String? highlightMilestoneTitle;

  static const String fase1 = 'Planificación';
  static const String fase2 = 'Desarrollo';
  static const String fase3 = 'Revisión';
  static const String fase4 = 'Completados';
  static const List<String> _columnTitles = [fase1, fase2, fase3, fase4];

  Color _getBorderColor(String faseTitle) {
    switch (faseTitle) {
      case fase1:
        return AppColors.accentRed;
      case fase2:
        return AppColors.accentOrange;
      case fase3:
        return AppColors.cyberBlue;
      case fase4:
        return AppColors.accentGreen;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final Map<String, List<Milestone>> columns = {
      fase1: [],
      fase2: [],
      fase3: [],
      fase4: []
    };

    for (var milestone in project.milestones) {
      if (milestone.fase == MilestoneFase.planificacion) {
        columns[fase1]!.add(milestone);
      } else if (milestone.fase == MilestoneFase.desarrollo)
        columns[fase2]!.add(milestone);
      else if (milestone.fase == MilestoneFase.revision)
        columns[fase3]!.add(milestone);
      if (milestone.status == MilestoneStatus.completed)
        columns[fase4]!.add(milestone);
    }

    return PageView.builder(
      controller: controller,
      itemCount: 10000,
      itemBuilder: (context, index) {
        final int realIndex = index % _columnTitles.length;
        final title = _columnTitles[realIndex];
        return SizedBox(
            width: screenWidth,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: KanbanColumn(
                    title: title,
                    borderColor: _getBorderColor(title),
                    children: columns[title]!
                        .map((milestone) => _KanbanMilestoneCard(
                            project: project,
                            milestone: milestone,
                            glowColor: _getBorderColor(title),
                            highlightMilestoneTitle: highlightMilestoneTitle))
                        .toList())));
      },
    );
  }
}
