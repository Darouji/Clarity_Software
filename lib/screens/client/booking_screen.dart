// lib/screens/client/booking_screen.dart
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

  Future<void> _rescheduleAppointment(Appointment apt) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: apt.date,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                    primary: AppColors.cyberBlue,
                    surface: AppColors.cardBackground)),
            child: child!));
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(apt.date),
          builder: (context, child) => Theme(
              data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                      primary: AppColors.cyberBlue,
                      surface: AppColors.cardBackground)),
              child: child!));
      if (pickedTime != null) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(apt.id)
            .update({
          'date': DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
                  pickedTime.hour, pickedTime.minute)
              .toIso8601String(),
          'status': 'pending', // Vuelve a pendiente
        });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Solicitud de cambio enviada"),
              backgroundColor: AppColors.cyberBlue));
      }
    }
  }

  // (Lógica de crear cita omitida para brevedad, es la misma que ya tenías funcional)
  // ... _selectDate, _selectTime, _submitRequest, _showRequestDialog ...
  Future<void> _selectDate(
      BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                    primary: AppColors.cyberBlue,
                    surface: AppColors.cardBackground)),
            child: child!));
    if (picked != null) setModalState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(
      BuildContext context, StateSetter setModalState) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
        builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                    primary: AppColors.cyberBlue,
                    surface: AppColors.cardBackground)),
            child: child!));
    if (picked != null) setModalState(() => _selectedTime = picked);
  }

  void _submitRequest(BuildContext ctx) async {
    if (_titleController.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Datos incompletos')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final newId =
          FirebaseFirestore.instance.collection('appointments').doc().id;
      final fullDate = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      await _appointmentService.createAppointment(Appointment(
          id: newId,
          clientId: widget.userId,
          clientName: "Usuario",
          title: _titleController.text,
          description: _descController.text,
          date: fullDate,
          status: 'pending',
          createdAt: DateTime.now()));
      if (mounted) {
        Navigator.pop(ctx);
        _titleController.clear();
        _descController.clear();
        _selectedDate = null;
        _selectedTime = null;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Solicitud enviada'),
            backgroundColor: AppColors.cyberBlue));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error'), backgroundColor: AppColors.accentRed));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showRequestDialog() {
    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (context, setModalState) => AlertDialog(
                    backgroundColor: AppColors.cardBackground,
                    title: const Text("Nueva Cita",
                        style: TextStyle(color: Colors.white)),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              labelText: "Motivo",
                              labelStyle: TextStyle(color: Colors.white54))),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () =>
                                    _selectDate(context, setModalState),
                                child: Text(_selectedDate == null
                                    ? "Fecha"
                                    : "${_selectedDate!.day}/${_selectedDate!.month}"))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () =>
                                    _selectTime(context, setModalState),
                                child: Text(_selectedTime == null
                                    ? "Hora"
                                    : "${_selectedTime!.hour}:${_selectedTime!.minute}")))
                      ])
                    ]),
                    actions: [
                      ElevatedButton(
                          onPressed: () => _submitRequest(ctx),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cyberBlue),
                          child: const Text("Enviar",
                              style: TextStyle(color: Colors.black)))
                    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
          title: const Text("Gestión de Citas",
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.cardBackground,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Column(children: [
        Expanded(
            child: StreamBuilder<List<Appointment>>(
          stream:
              _appointmentService.getClientAppointmentsStream(widget.userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.cyberBlue));
            if (snapshot.data!.isEmpty)
              return const Center(
                  child: Text("Sin citas.",
                      style: TextStyle(color: Colors.white54)));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final apt = snapshot.data![index];
                return AppointmentCard(
                  appointment: apt,
                  isAdmin: widget.isAdmin,
                  // HABILITAMOS ACCIONES PARA EL CLIENTE
                  onReject: () async {
                    await _appointmentService.deleteAppointment(apt.id);
                  },
                  onReschedule: () => _rescheduleAppointment(apt),
                  onApprove: widget.isAdmin
                      ? () => _appointmentService.updateAppointmentStatus(
                          apt.id, 'approved')
                      : null,
                );
              },
            );
          },
        ))
      ]),
      floatingActionButton: !widget.isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.cyberBlue,
              onPressed: _showRequestDialog,
              child: const Icon(Icons.add, color: Colors.black))
          : null,
    );
  }
}
