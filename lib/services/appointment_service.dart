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

  // Eliminar cita
  Future<void> deleteAppointment(String appointmentId) async {
    await _db.collection('appointments').doc(appointmentId).delete();
  }
}
