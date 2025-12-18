import 'package:flutter/material.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/widgets/calendar_widget.dart';
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
        title: const Text("Gestión de Citas",
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Calendario
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.cardBackground,
              // CORRECCIÓN: CalendarWidget requiere 'projects' y no tiene 'onDateSelected'
              child: const CalendarWidget(
                projects: [], // Lista vacía temporalmente para cumplir el contrato
              ),
            ),
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Próximas Reuniones",
                  style: TextStyle(
                      color: AppColors.cyberBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<Appointment>>(
                // CORRECCIÓN: Método correcto es getClientAppointmentsStream
                stream: _appointmentService
                    .getClientAppointmentsStream(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.cyberBlue));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("No hay citas programadas.",
                            style: TextStyle(color: Colors.white54)));
                  }

                  final appointments = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 8, left: 16, right: 16, bottom: 80),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final apt = appointments[index];
                      return AppointmentCard(
                        appointment: apt,
                        isAdmin: widget.isAdmin,
                        // CORRECCIÓN: AppointmentCard usa onApprove/onReject, no onStatusChanged
                        onApprove: () {
                          _appointmentService.updateAppointmentStatus(
                              apt.id, 'approved');
                        },
                        onReject: () {
                          _appointmentService.updateAppointmentStatus(
                              apt.id, 'rejected');
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
              backgroundColor: AppColors.cyberBlue,
              onPressed: () => _showRequestAppointmentDialog(context),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text("Solicitar Reunión",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  void _showRequestAppointmentDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: AppColors.cardBackground,
              title: const Text("Solicitar Cita",
                  style: TextStyle(color: Colors.white)),
              content: const Text("Funcionalidad para elegir fecha y hora.",
                  style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cerrar"))
              ],
            ));
  }
}
