// lib/services/appointment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todas las citas (Para Admin)
  Stream<List<Appointment>> getAllAppointmentsStream() {
    return _db
        .collection('appointments')
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Appointment.fromJson(doc.data()))
              .toList(),
        );
  }

  // Obtener citas de un cliente específico
  Stream<List<Appointment>> getClientAppointmentsStream(String clientId) {
    return _db
        .collection('appointments')
        .where('clientId', isEqualTo: clientId)
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Appointment.fromJson(doc.data()))
              .toList(),
        );
  }

  // NUEVO: Contar citas pendientes para el Badge del Admin
  Stream<int> getPendingCountStream() {
    return _db
        .collection('appointments')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Crear una nueva cita
  Future<void> createAppointment(Appointment appointment) async {
    await _db
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toJson());
  }

  // Actualizar estado (Aprobar/Rechazar)
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': newStatus,
    });
  }

  // Proponer reagendamiento (Admin)
  Future<void> proposeReschedule(String appointmentId, DateTime newDate) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'date': newDate.toIso8601String(),
      'status': 'reschedule_proposal',
    });
  }

  // Eliminar cita
  Future<void> deleteAppointment(String appointmentId) async {
    await _db.collection('appointments').doc(appointmentId).delete();
  }
}
