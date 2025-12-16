// lib/screens/admin/admin_appointments_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentService appointmentService = AppointmentService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor: AppColors.appBarBackground.withValues(
                alpha: 0.8,
              ),
              elevation: 0,
              leading: const BackButton(color: Colors.white),
              title: const Text(
                'Gestión de Citas',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: const [GlobalAppBarMenu(currentScreen: AppScreen.admin)],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: appointmentService.getAllAppointmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyberBlue),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar citas',
                style: TextStyle(color: AppColors.accentRed),
              ),
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, size: 60, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'No hay citas pendientes.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final apt = appointments[index];
              Color statusColor;
              String statusText;

              switch (apt.status) {
                case 'approved':
                  statusColor = AppColors.accentGreen;
                  statusText = 'Aprobada';
                  break;
                case 'rejected':
                  statusColor = AppColors.accentRed;
                  statusText = 'Rechazada';
                  break;
                default:
                  statusColor = AppColors.accentOrange;
                  statusText = 'Pendiente';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NeonCard(
                  glowColor: statusColor.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            apt.clientName,
                            style: const TextStyle(
                              color: AppColors.cyberBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        apt.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${apt.date.day}/${apt.date.month}/${apt.date.year} - ${apt.date.hour}:${apt.date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (apt.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          apt.description,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      if (apt.status == 'pending') ...[
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                appointmentService.updateAppointmentStatus(
                                  apt.id,
                                  'rejected',
                                );
                              },
                              child: const Text(
                                'Rechazar',
                                style: TextStyle(color: AppColors.accentRed),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                appointmentService.updateAppointmentStatus(
                                  apt.id,
                                  'approved',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGreen,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Aprobar'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
