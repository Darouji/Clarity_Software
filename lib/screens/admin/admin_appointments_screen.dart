// lib/screens/admin/admin_appointments_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/appointment_card.dart';
import 'package:flutter/material.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

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
                hourMinuteTextColor: Colors.white,
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
            const SnackBar(
              content: Text('Propuesta de reagendamiento enviada al cliente'),
              backgroundColor: AppColors.cyberBlue,
            ),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        // EFECTO CRISTAL NEGRO
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              color: Colors.black.withOpacity(0.3), // Negro con transparencia
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
            // Padding ajustado para empezar bajo el banner
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 20),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final apt = appointments[index];

              return AppointmentCard(
                appointment: apt,
                isAdmin: true,
                onApprove: () {
                  appointmentService.updateAppointmentStatus(
                    apt.id,
                    'approved',
                  );
                },
                onReject: () {
                  appointmentService.updateAppointmentStatus(
                    apt.id,
                    'rejected',
                  );
                },
                onReschedule: () =>
                    _handleReschedule(context, apt, appointmentService),
              );
            },
          );
        },
      ),
    );
  }
}
