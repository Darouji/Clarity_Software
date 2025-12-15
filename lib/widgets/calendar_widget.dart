// lib/widgets/calendar_widget.dart
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarWidget extends StatelessWidget {
  final List<Project> projects;

  const CalendarWidget({super.key, required this.projects});

  Future<void> _openGoogleCalendar() async {
    final Uri url = Uri.parse('https://calendar.google.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir el calendario');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Aplanar la lista: Obtener todos los hitos pendientes de todos los proyectos
    final allMilestones = projects.expand((p) {
      return p.milestones
          .where(
            (m) =>
                // Filtramos solo los que no están completados y tienen fecha futura o reciente
                m.status.toString() != 'MilestoneStatus.completed',
          )
          .map(
            (m) => MapEntry(m, p.name),
          ); // Guardamos par (Hito, NombreProyecto)
    }).toList();

    // 2. Ordenar por fecha de vencimiento (deadline)
    allMilestones.sort((a, b) => a.key.deadline.compareTo(b.key.deadline));

    // 3. Tomar solo los próximos 3 para no saturar
    final upcoming = allMilestones.take(3).toList();

    return NeonCard(
      glowColor: AppColors.accentMagenta.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.accentMagenta,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Agenda Próxima',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.open_in_new,
                  color: Colors.white54,
                  size: 18,
                ),
                onPressed: _openGoogleCalendar,
                tooltip: 'Abrir Google Calendar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No hay eventos próximos.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            ...upcoming.map((entry) {
              final milestone = entry.key;
              final projectName = entry.value;
              final dateStr = DateFormat('dd MMM').format(milestone.deadline);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentMagenta.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.accentMagenta.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        dateStr,
                        style: const TextStyle(
                          color: AppColors.accentMagenta,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            projectName,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

          if (upcoming.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _openGoogleCalendar,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentMagenta,
                  ),
                  child: const Text('VER CALENDARIO COMPLETO'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
