// lib/screens/client/booking_screen.dart
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentMagenta,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentMagenta,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona fecha y hora')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) return;

      // Combinar Fecha y Hora
      final fullDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final appointment = Appointment(
        id: '', // Se genera auto
        clientId: user.id,
        projectId: '', // General por ahora
        reason: _reasonController.text,
        requestedDate: fullDate,
        status: AppointmentStatus.pending,
        createdAt: DateTime.now(),
      );

      await _appointmentService.requestAppointment(appointment);

      if (!mounted) return;

      // Mostrar éxito y salir
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Solicitud Enviada',
            style: TextStyle(color: AppColors.accentGreen),
          ),
          content: const Text(
            'El administrador revisará tu solicitud y recibirás una notificación cuando sea confirmada.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver atrás
              },
              child: const Text(
                'Entendido',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Visita/Reunión'),
        actions: const [GlobalAppBarMenu(currentScreen: AppScreen.overview)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Solicitar Disponibilidad',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentMagenta,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona un bloque horario preferido. El administrador confirmará la disponibilidad.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 30),

              // --- SELECTORES DE FECHA/HORA ---
              Row(
                children: [
                  Expanded(
                    child: _buildSelector(
                      icon: Icons.calendar_today,
                      label: _selectedDate == null
                          ? 'Fecha'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSelector(
                      icon: Icons.access_time,
                      label: _selectedTime == null
                          ? 'Hora'
                          : _selectedTime!.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- MOTIVO ---
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Motivo de la reunión',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.cardBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Por favor indica el motivo' : null,
              ),
              const SizedBox(height: 40),

              // --- BOTÓN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentMagenta,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ENVIAR SOLICITUD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelector({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.cyberBlue),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
