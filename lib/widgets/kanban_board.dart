// lib/widgets/kanban_board.dart
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/kanban_column.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/models/feedback_message.dart';
import 'package:clarity_software/services/feedback_notification_service.dart';

class _KanbanMilestoneCard extends StatefulWidget {
  final String projectId;
  final Milestone milestone;
  final Color glowColor;
  // --- INICIO DE CAMBIOS ---
  // Aceptamos el título del hito a resaltar
  final String? highlightMilestoneTitle;
  // --- FIN DE CAMBIOS ---

  const _KanbanMilestoneCard({
    required this.projectId,
    required this.milestone,
    required this.glowColor,
    this.highlightMilestoneTitle, // <-- Nuevo
  });

  @override
  State<_KanbanMilestoneCard> createState() => _KanbanMilestoneCardState();
}

class _KanbanMilestoneCardState extends State<_KanbanMilestoneCard> {
  final FeedbackNotificationService _feedbackService =
      FeedbackNotificationService();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isExpanded = false;
  List<FeedbackMessage> _feedbackHistory = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbackHistory();

    // --- INICIO DE CAMBIOS: Auto-expandir y marcar como leído ---
    if (widget.highlightMilestoneTitle == widget.milestone.title) {
      _isExpanded = true;
      // Marcamos como leído tan pronto como se muestra
      _feedbackService.markMilestoneFeedbackAsRead(
        widget.projectId,
        widget.milestone.title,
      );
      // Recargamos el historial para que el indicador de "no leído" desaparezca
      _loadFeedbackHistory();
    }
    // --- FIN DE CAMBIOS ---
  }

  void _loadFeedbackHistory() {
    setState(() {
      _feedbackHistory = _feedbackService.getFeedbackForMilestone(
        widget.projectId,
        widget.milestone.title,
      );
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        // Si se expande manualmente, también marcamos como leído
        _feedbackService.markMilestoneFeedbackAsRead(
          widget.projectId,
          widget.milestone.title,
        );
        _loadFeedbackHistory();
      }
    });
  }

  void _submitFeedback(FeedbackType type) async {
    // --- INICIO DE CORRECCIÓN: Chequeo de BuildContext ---
    if (!mounted) return;
    // --- FIN DE CORRECCIÓN ---

    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe un mensaje de feedback.'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    await _feedbackService.addFeedback(
      projectId: widget.projectId,
      milestoneTitle: widget.milestone.title,
      message: _feedbackController.text,
      type: type,
      author: 'Cliente',
    );

    _feedbackController.clear();
    _loadFeedbackHistory();
    setState(() {
      _isExpanded = false;
    });

    // --- INICIO DE CORRECCIÓN: Chequeo de BuildContext ---
    if (!mounted) return;
    // --- FIN DE CORRECCIÓN ---
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          type == FeedbackType.approval
              ? 'Hito aprobado con éxito.'
              : 'Cambios solicitados.',
        ),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color progressColor;
    if (widget.milestone.status == MilestoneStatus.completed) {
      progressColor = AppColors.accentGreen;
    } else if (widget.milestone.status == MilestoneStatus.inProgress) {
      progressColor = (widget.milestone.progress >= 0.7)
          ? AppColors.cyberBlue
          : AppColors.accentOrange;
    } else {
      progressColor = AppColors.accentRed;
    }

    final int unreadCount = _feedbackHistory
        .where((f) => !f.isRead && f.author != 'Cliente')
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: NeonCard(
        glowColor: widget.glowColor.withAlpha(40),
        padding: const EdgeInsets.all(12.0),
        child: InkWell(
          onTap: _toggleExpand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.milestone.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (unreadCount > 0 && !_isExpanded)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.accentRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.milestone.status.toString().split('.').last,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: progressColor),
                  ),
                  Text(
                    '${(widget.milestone.progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: LinearProgressIndicator(
                  value: widget.milestone.progress,
                  minHeight: 6,
                  backgroundColor: progressColor.withAlpha((255 * 0.2).round()),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              if (_isExpanded) _buildFeedbackSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.grey),
          const SizedBox(height: 8),
          const Text(
            'Enviar Retroalimentación:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje...',
              filled: true,
              // --- CORRECCIÓN LINT ---
              fillColor: AppColors.primaryBackground.withAlpha(
                (255 * 0.5).round(),
              ), // withAlpha
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                // --- CORRECCIÓN LINT ---
                borderSide: BorderSide(
                  color: AppColors.grey.withAlpha((255 * 0.5).round()),
                ), // withAlpha
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                // --- CORRECCIÓN LINT ---
                borderSide: BorderSide(
                  color: AppColors.grey.withAlpha((255 * 0.5).round()),
                ), // withAlpha
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.cardBlack,
                  ),
                  onPressed: () => _submitFeedback(FeedbackType.approval),
                  child: const Text(
                    'Aprobar Hito',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _submitFeedback(FeedbackType.changeRequest),
                  child: const Text(
                    'Solicitar Cambios',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          if (_feedbackHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.grey),
            const SizedBox(height: 8),
            const Text(
              'Historial de Feedback:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            ..._feedbackHistory.map((msg) => _buildHistoryTile(msg)),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTile(FeedbackMessage msg) {
    final bool isApproval = msg.type == FeedbackType.approval;
    final Color color = isApproval
        ? AppColors.accentGreen
        : AppColors.accentRed;
    final IconData icon = isApproval ? Icons.check_circle : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
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
                    fontSize: 12,
                  ),
                ),
                Text(msg.message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({
    super.key,
    required this.projectId,
    required this.milestones,
    this.controller,
    this.highlightMilestoneTitle, // <-- Acepta el título a resaltar
  });

  final String projectId;
  final List<Milestone> milestones;
  final PageController? controller;
  // --- INICIO DE CAMBIOS ---
  final String? highlightMilestoneTitle; // <-- Nueva propiedad
  // --- FIN DE CAMBIOS ---

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
      fase4: [],
    };

    for (var milestone in milestones) {
      if (milestone.fase == MilestoneFase.planificacion) {
        columns[fase1]!.add(milestone);
      } else if (milestone.fase == MilestoneFase.desarrollo) {
        columns[fase2]!.add(milestone);
      } else if (milestone.fase == MilestoneFase.revision) {
        columns[fase3]!.add(milestone);
      }

      if (milestone.status == MilestoneStatus.completed) {
        columns[fase4]!.add(milestone);
      }
    }

    return PageView.builder(
      controller: controller,
      itemCount: 10000,
      itemBuilder: (context, index) {
        final int realIndex = index % _columnTitles.length;
        final title = _columnTitles[realIndex];

        final milestoneList = columns[title]!;
        final borderColor = _getBorderColor(title);

        return SizedBox(
          width: screenWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: KanbanColumn(
              title: title,
              borderColor: borderColor,
              children: milestoneList.map((milestone) {
                return _KanbanMilestoneCard(
                  projectId: projectId,
                  milestone: milestone,
                  glowColor: borderColor,
                  // --- INICIO DE CAMBIO ---
                  // Pasamos el título a resaltar a la tarjeta
                  highlightMilestoneTitle: highlightMilestoneTitle,
                  // --- FIN DE CAMBIO ---
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
