// lib/widgets/appointment_card.dart
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onReschedule;
  final bool isAdmin;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onApprove,
    this.onReject,
    this.onReschedule,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final String cleanStatus = appointment.status.trim().toLowerCase();

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (cleanStatus) {
      case 'approved':
        statusColor = AppColors.accentGreen;
        statusText = 'Aprobada';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        statusColor = AppColors.accentRed;
        statusText = 'Rechazada';
        statusIcon = Icons.cancel_outlined;
        break;
      case 'reschedule_proposal':
        statusColor = AppColors.cyberBlue;
        statusText = 'Propuesta de Cambio';
        statusIcon = Icons.update;
        break;
      case 'pending':
      default:
        statusColor = AppColors.accentOrange;
        statusText = 'Pendiente';
        statusIcon = Icons.hourglass_empty;
    }

    final bool showAdminActions = isAdmin && cleanStatus != 'rejected';
    final bool showClientActions =
        !isAdmin && cleanStatus == 'reschedule_proposal';
    final bool showPendingActions = isAdmin && cleanStatus == 'pending';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: NeonCard(
        glowColor: statusColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.clientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fecha
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: AppColors.cyberBlue, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time,
                    color: AppColors.cyberBlue, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${appointment.date.hour}:${appointment.date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              appointment.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (appointment.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                appointment.description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // --- ACCIONES (CORREGIDO: Botones compactos en fila) ---
            if (showAdminActions || showClientActions) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ADMIN: Botón de Reagendar (Compacto)
                  if (showAdminActions)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: TextButton.icon(
                        onPressed: onReschedule,
                        // Ajustes para compactar
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          visualDensity: VisualDensity.compact,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.edit_calendar,
                            size: 14, color: AppColors.cyberBlue),
                        label: const Text(
                          'Reagendar',
                          style: TextStyle(
                              color: AppColors.cyberBlue, fontSize: 12),
                        ),
                      ),
                    ),

                  // Espaciador flexible si es necesario, o fijo pequeño
                  if (showAdminActions && showPendingActions)
                    const SizedBox(width: 4),

                  // ADMIN: Aprobar/Rechazar (Botones más pequeños)
                  if (showPendingActions) ...[
                    OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentRed,
                        side: const BorderSide(color: AppColors.accentRed),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(0, 32), // Altura reducida
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Rechazar',
                          style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(0, 32), // Altura reducida
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child:
                          const Text('Aprobar', style: TextStyle(fontSize: 12)),
                    ),
                  ],

                  // CLIENTE: Confirmar/Rechazar Propuesta (Igual tratamiento compacto)
                  if (showClientActions) ...[
                    OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentRed,
                        side: const BorderSide(color: AppColors.accentRed),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Rechazar',
                          style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyberBlue,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Confirmar',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
