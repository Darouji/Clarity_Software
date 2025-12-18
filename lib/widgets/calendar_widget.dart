// lib/widgets/calendar_widget.dart
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/booking_screen.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  final List<Project> projects;

  const CalendarWidget({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final AppointmentService appointmentService = AppointmentService();

    return NeonCard(
      glowColor: AppColors.cyberBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Agenda Próxima',
                  style: TextStyle(
                      color: AppColors.cyberBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Icon(Icons.calendar_month, color: AppColors.cyberBlue, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: userId == null
                ? const LinearProgressIndicator(color: AppColors.cyberBlue)
                : StreamBuilder<List<Appointment>>(
                    stream:
                        appointmentService.getClientAppointmentsStream(userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Text('Cargando...',
                            style: TextStyle(color: Colors.white54));
                      final now = DateTime.now();
                      final futureAppointments = snapshot.data!
                          .where((a) => a.date
                              .isAfter(now.subtract(const Duration(hours: 2))))
                          .take(2)
                          .toList();

                      if (futureAppointments.isEmpty) {
                        return const Align(
                            alignment: Alignment.topLeft,
                            child: Text('No tienes reuniones programadas.',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13)));
                      }

                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: futureAppointments.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: Colors.white10, height: 16),
                        itemBuilder: (context, index) {
                          final apt = futureAppointments[index];
                          // WRAP CON INKWELL PARA NAVEGACIÓN INDIVIDUAL
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BookingScreen(userId: userId)));
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: AppColors.cyberBlue
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.cyberBlue
                                              .withValues(alpha: 0.3))),
                                  child: Column(children: [
                                    Text('${apt.date.day}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(_getMonth(apt.date.month),
                                        style: const TextStyle(
                                            color: AppColors.cyberBlue,
                                            fontSize: 10))
                                  ]),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(apt.title,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${apt.date.hour}:${apt.date.minute.toString().padLeft(2, '0')} hrs',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12))
                                    ])),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () {
                    if (userId != null)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BookingScreen(userId: userId)));
                  },
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.cyberBlue.withValues(alpha: 0.3)),
                      foregroundColor: AppColors.cyberBlue,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      visualDensity: VisualDensity.compact),
                  child: const Text('Ver Agenda Completa'))),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC'
    ];
    return months[month - 1];
  }
}
