// lib/screens/client/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/widgets/appointment_card.dart';

class BookingScreen extends StatefulWidget {
  final String userId;
  final bool isAdmin;

  const BookingScreen({super.key, required this.userId, this.isAdmin = false});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final AppointmentService _appointmentService = AppointmentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          "Gestión de Citas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                "Tus Reuniones",
                style: TextStyle(
                  color: AppColors.cyberBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Appointment>>(
                stream: _appointmentService
                    .getClientAppointmentsStream(widget.userId),
                builder: (context, snapshot) {
                  // Manejo visual de errores del Stream
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "No se pudieron cargar las citas.\nVerifica tu conexión o permisos.\nError: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.accentRed),
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.cyberBlue),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy,
                              size: 50, color: Colors.white24),
                          SizedBox(height: 16),
                          Text(
                            "No tienes citas programadas.",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  }

                  final appointments = snapshot.data!;

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final apt = appointments[index];
                      return AppointmentCard(
                        appointment: apt,
                        isAdmin: widget.isAdmin,
                        // CORRECCIÓN: Try-Catch para evitar cierres inesperados
                        onApprove: () async {
                          try {
                            await _appointmentService.updateAppointmentStatus(
                                apt.id, 'approved');
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Cita confirmada exitosamente"),
                                backgroundColor: AppColors.accentGreen,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Error al confirmar: Verifica tus permisos.\n$e"),
                                backgroundColor: AppColors.accentRed,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        onReject: () async {
                          try {
                            await _appointmentService.updateAppointmentStatus(
                                apt.id, 'rejected');
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Cita rechazada"),
                                backgroundColor: AppColors.accentRed,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Error al rechazar: Verifica tus permisos.\n$e"),
                                backgroundColor: AppColors.accentRed,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !widget.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.cyberBlue.withValues(alpha: 0.5),
              elevation: 0,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "La solicitud de citas estará disponible próximamente."),
                    backgroundColor: AppColors.cardBackground,
                  ),
                );
              },
              icon: const Icon(Icons.add_alarm, color: Colors.white54),
              label: const Text(
                "Solicitar Reunión",
                style: TextStyle(
                    color: Colors.white54, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
