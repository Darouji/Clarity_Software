// lib/widgets/appointment_card.dart
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onReschedule; // Nuevo callback para reagendar
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
    Color statusColor;
    String statusText;
    IconData statusIcon;

    // Lógica basada en String
    switch (appointment.status) {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: NeonCard(
        glowColor: statusColor.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Cliente y Estado
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
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

            // Fecha y Hora
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.cyberBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  color: AppColors.cyberBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${appointment.date.hour}:${appointment.date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Motivo
            Text(
              appointment.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Descripción opcional
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

            // --- ACCIONES (BOTONES) ---
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ADMIN: Botón de Reagendar (Siempre visible si no está rechazada final)
                if (isAdmin && appointment.status != 'rejected') ...[
                  TextButton.icon(
                    onPressed: onReschedule,
                    icon: const Icon(Icons.edit_calendar,
                        size: 16, color: AppColors.cyberBlue),
                    label: const Text(
                      'Reagendar',
                      style: TextStyle(color: AppColors.cyberBlue),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // ADMIN: Aprobar/Rechazar (Solo si pendiente)
                if (isAdmin && appointment.status == 'pending') ...[
                  OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentRed,
                      side: const BorderSide(color: AppColors.accentRed),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Aprobar'),
                  ),
                ],

                // CLIENTE: Confirmar/Rechazar Propuesta de Cambio
                if (!isAdmin &&
                    appointment.status == 'reschedule_proposal') ...[
                  OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentRed,
                      side: const BorderSide(color: AppColors.accentRed),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onApprove, // Aprueba el cambio
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyberBlue,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Confirmar Cambio'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
