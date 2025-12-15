// lib/models/appointment.dart

enum AppointmentStatus { pending, approved, rejected, completed }

class Appointment {
  final String id;
  final String clientId;
  final String
  projectId; // Opcional, si la cita es sobre un proyecto específico
  final String reason; // "Revisión de avance", "Visita técnica", etc.
  final DateTime requestedDate; // La fecha que el cliente quiere
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? adminNotes; // Respuesta del admin (ej. "Te llamo antes")

  Appointment({
    required this.id,
    required this.clientId,
    required this.projectId,
    required this.reason,
    required this.requestedDate,
    required this.status,
    required this.createdAt,
    this.adminNotes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      projectId: json['projectId'] ?? '',
      reason: json['reason'] ?? '',
      requestedDate: DateTime.parse(json['requestedDate']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      adminNotes: json['adminNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'projectId': projectId,
      'reason': reason,
      'requestedDate': requestedDate.toIso8601String(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'adminNotes': adminNotes,
    };
  }
}
