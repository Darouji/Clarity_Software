// lib/widgets/appointment_card.dart
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/services/user_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  Future<void> _updateStatus(
    BuildContext context,
    AppointmentStatus status,
  ) async {
    final AppointmentService service = AppointmentService();
    await service.updateAppointmentStatus(appointment.id, status);

    if (!context.mounted) return;

    String message = status == AppointmentStatus.approved
        ? 'Cita aprobada'
        : 'Cita rechazada';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: status == AppointmentStatus.approved
            ? AppColors.accentGreen
            : AppColors.accentRed,
      ),
    );

    // Si se aprueba, sugerimos abrir el calendario para agendarla manualmente
    if (status == AppointmentStatus.approved) {
      _openCalendar();
    }
  }

  Future<void> _openCalendar() async {
    final Uri url = Uri.parse('https://calendar.google.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir el calendario');
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    return FutureBuilder<ClientUser?>(
      future: userService.getUserById(appointment.clientId),
      builder: (context, snapshot) {
        final clientName = snapshot.data?.name ?? 'Cliente Desconocido';
        final clientEmail = snapshot.data?.email ?? '---';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: NeonCard(
            glowColor: AppColors.cyberBlue.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: Nombre y Fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            clientEmail,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cyberBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.cyberBlue.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat(
                              'dd MMM',
                            ).format(appointment.requestedDate),
                            style: const TextStyle(
                              color: AppColors.cyberBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat(
                              'HH:mm',
                            ).format(appointment.requestedDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),

                // Motivo
                const Text(
                  'MOTIVO:',
                  style: TextStyle(
                    color: AppColors.accentMagenta,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.reason,
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _updateStatus(context, AppointmentStatus.rejected),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentRed,
                          side: const BorderSide(color: AppColors.accentRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('RECHAZAR'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _updateStatus(context, AppointmentStatus.approved),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'APROBAR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
