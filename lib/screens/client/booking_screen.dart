// lib/screens/client/booking_screen.dart
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- Lógica de formulario omitida para brevedad (es la misma que antes) ---
  // (Mantén aquí las funciones _selectDate, _selectTime, _submitRequest, _showRequestDialog tal cual estaban)

  Future<void> _selectDate(
      BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
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
    if (picked != null) {
      setModalState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, StateSetter setModalState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
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
    if (picked != null) {
      setModalState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitRequest(BuildContext dialogContext) async {
    if (_titleController.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor completa el motivo, fecha y hora.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final DateTime fullDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final String newId =
          FirebaseFirestore.instance.collection('appointments').doc().id;

      final newAppointment = Appointment(
        id: newId,
        clientId: widget.userId,
        clientName: "Usuario Actual",
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: fullDateTime,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _appointmentService.createAppointment(newAppointment);

      if (mounted) {
        Navigator.pop(dialogContext);
        _titleController.clear();
        _descController.clear();
        _selectedDate = null;
        _selectedTime = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada al administrador.'),
            backgroundColor: AppColors.cyberBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al solicitar: $e'),
              backgroundColor: AppColors.accentRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isSubmitting,
      builder: (BuildContext dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Solicitar Reunión",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child:
                            LinearProgressIndicator(color: AppColors.cyberBlue),
                      ),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Motivo de la reunión",
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.cyberBlue)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Detalles adicionales (Opcional)",
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.cyberBlue)),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _selectDate(context, setModalState),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _selectedDate == null
                                  ? Colors.white54
                                  : AppColors.cyberBlue,
                              side: BorderSide(
                                  color: _selectedDate == null
                                      ? Colors.white24
                                      : AppColors.cyberBlue),
                            ),
                            label: Text(
                              _selectedDate == null
                                  ? "Fecha"
                                  : "${_selectedDate!.day}/${_selectedDate!.month}",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _selectTime(context, setModalState),
                            icon: const Icon(Icons.access_time, size: 16),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _selectedTime == null
                                  ? Colors.white54
                                  : AppColors.cyberBlue,
                              side: BorderSide(
                                  color: _selectedTime == null
                                      ? Colors.white24
                                      : AppColors.cyberBlue),
                            ),
                            label: Text(
                              _selectedTime == null
                                  ? "Hora"
                                  : "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                if (!_isSubmitting)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text("Cancelar",
                        style: TextStyle(color: Colors.white54)),
                  ),
                ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : () => _submitRequest(dialogCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyberBlue,
                    foregroundColor: Colors.black,
                  ),
                  child:
                      Text(_isSubmitting ? "Enviando..." : "Enviar Solicitud"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparencia total base
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Gestión de Citas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Espacio para librar el AppBar
          const SizedBox(height: 100),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Error al cargar citas: ${snapshot.error}",
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
                        Icon(Icons.event_busy, size: 50, color: Colors.white24),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final apt = appointments[index];
                    return AppointmentCard(
                      appointment: apt,
                      isAdmin: widget.isAdmin,
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
                              content: Text("Error al confirmar: $e"),
                              backgroundColor: AppColors.accentRed,
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
                              content: Text("Error al rechazar: $e"),
                              backgroundColor: AppColors.accentRed,
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
      floatingActionButton: !widget.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.cyberBlue,
              elevation: 4,
              onPressed: _isSubmitting ? null : _showRequestDialog,
              icon: const Icon(Icons.add_alarm, color: Colors.black),
              label: const Text(
                "Solicitar Reunión",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
