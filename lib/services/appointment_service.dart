// lib/services/appointment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/appointment.dart';

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  // --- CREAR SOLICITUD ---
  Future<void> requestAppointment(Appointment appointment) async {
    // Dejamos que Firestore genere el ID si viene vacío
    final docRef = _db.collection(_collection).doc();

    final newAppointment = Appointment(
      id: docRef.id,
      clientId: appointment.clientId,
      projectId: appointment.projectId,
      reason: appointment.reason,
      requestedDate: appointment.requestedDate,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
      adminNotes: null,
    );

    await docRef.set(newAppointment.toJson());
  }

  // --- LEER (Para el Cliente) ---
  Stream<List<Appointment>> getAppointmentsForClient(String clientId) {
    return _db
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('requestedDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Appointment.fromJson(data);
          }).toList();
        });
  }

  // --- LEER (Para el Admin - Pendientes) ---
  Stream<List<Appointment>> getPendingAppointments() {
    return _db
        .collection(_collection)
        .where('status', isEqualTo: AppointmentStatus.pending.toString())
        .orderBy('requestedDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Appointment.fromJson(data);
          }).toList();
        });
  }

  // --- ACTUALIZAR ESTADO (Aprobar/Rechazar) ---
  Future<void> updateAppointmentStatus(
    String id,
    AppointmentStatus status, {
    String? notes,
  }) async {
    final Map<String, dynamic> updates = {'status': status.toString()};
    if (notes != null) {
      updates['adminNotes'] = notes;
    }

    await _db.collection(_collection).doc(id).update(updates);
  }
}
