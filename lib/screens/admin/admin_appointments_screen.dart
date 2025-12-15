// lib/screens/admin/admin_appointments_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/appointment_card.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:flutter/material.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentService appointmentService = AppointmentService();
    final theme = Theme.of(context);
    const double appBarHeight = 65.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: theme.appBarTheme.backgroundColor,
              child: SafeArea(
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(-1.0, 0.2),
                      child: BackButton(color: theme.iconTheme.color),
                    ),
                    const Align(
                      alignment: Alignment(0.0, 0.2),
                      child: Text(
                        'Solicitudes de Reunión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment(1.0, 0.2),
                      child: GlobalAppBarMenu(currentScreen: AppScreen.admin),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: appointmentService.getPendingAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyberBlue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.accentRed),
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
                  SizedBox(height: 20),
                  Text(
                    'No hay solicitudes pendientes.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final double topPadding = index == 0 ? appBarHeight + 20 : 0;

              return Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: AppointmentCard(appointment: appointment),
              );
            },
          );
        },
      ),
    );
  }
}
