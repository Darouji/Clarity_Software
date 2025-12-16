// lib/screens/client/booking_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/appointment.dart';
import 'package:clarity_software/services/appointment_service.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.cyberBlue,
              onPrimary: Colors.black,
              surface: AppColors.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Usuario no identificado');

      final DateTime finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newAppointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: user.id,
        clientName: user.name,
        title: _titleController.text,
        description: _descriptionController.text,
        date: finalDateTime,
        status: 'pending',
      );

      await _appointmentService.createAppointment(newAppointment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada con éxito'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agendar: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Agendar Cita',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: const [
                GlobalAppBarMenu(currentScreen: AppScreen.overview),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Solicitar Reunión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cyberBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona una fecha y hora para discutir los avances de tu proyecto.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),

              NeonCard(
                glowColor: AppColors.accentMagenta.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Motivo de la reunión',
                        labelStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(
                          Icons.label_outline,
                          color: AppColors.accentMagenta,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.accentMagenta,
                          ),
                        ),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Ingresa un motivo' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Detalles adicionales (Opcional)',
                        labelStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(
                          Icons.description_outlined,
                          color: AppColors.accentMagenta,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.accentMagenta,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: NeonCard(
                        glowColor: AppColors.cyberBlue.withValues(alpha: 0.2),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.cyberBlue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: NeonCard(
                        glowColor: AppColors.cyberBlue.withValues(alpha: 0.2),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.cyberBlue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyberBlue,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'ENVIAR SOLICITUD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
}
