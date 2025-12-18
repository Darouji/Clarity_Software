// lib/screens/admin/client_details_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/appointment_card.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class ClientDetailsScreen extends StatelessWidget {
  final ClientUser client;

  const ClientDetailsScreen({super.key, required this.client});

  Future<void> _handleReschedule(
      BuildContext context, Appointment apt, AppointmentService service) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: apt.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.cyberBlue,
              onPrimary: Colors.black,
              surface: AppColors.cardBackground,
              onSurface: Colors.white,
            ),
            // CORREGIDO: Usamos DialogThemeData para Flutter 3.27+
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.primaryBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(apt.date),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: const TimePickerThemeData(
                backgroundColor: AppColors.cardBackground,
                dialHandColor: AppColors.cyberBlue,
              ),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.cyberBlue,
                surface: AppColors.cardBackground,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        await service.proposeReschedule(apt.id, newDateTime);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Propuesta de cambio enviada')),
          );
        }
      }
    }
  }

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
              backgroundColor:
                  AppColors.appBarBackground.withValues(alpha: 0.8),
              elevation: 0,
              leading: const BackButton(color: Colors.white),
              title: Text(
                client.displayName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: const [GlobalAppBarMenu(currentScreen: AppScreen.admin)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bloque: Información del Cliente
            NeonCard(
              glowColor: AppColors.cyberBlue,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person,
                          color: AppColors.cyberBlue, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        "Información de Contacto",
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow("Email", client.email),
                  _buildInfoRow(
                      "Teléfono", client.phoneNumber ?? "No registrado"),
                  _buildInfoRow("Empresa", client.companyName ?? "Particular"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bloque: Historial de Reuniones
            const Text(
              "Historial de Reuniones",
              style: TextStyle(
                color: AppColors.cyberBlue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            StreamBuilder<List<Appointment>>(
              stream: appointmentService.getClientAppointmentsStream(client.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const NeonCard(
                    glowColor: Colors.grey,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "No hay historial de reuniones para este cliente.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  );
                }

                final appointments = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final apt = appointments[index];
                    return AppointmentCard(
                      appointment: apt,
                      isAdmin: true,
                      onApprove: () => appointmentService
                          .updateAppointmentStatus(apt.id, 'approved'),
                      onReject: () => appointmentService
                          .updateAppointmentStatus(apt.id, 'rejected'),
                      onReschedule: () =>
                          _handleReschedule(context, apt, appointmentService),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white54, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
