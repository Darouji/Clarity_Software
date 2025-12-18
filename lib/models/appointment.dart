// lib/models/appointment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final String title;
  final String description;
  final DateTime date;
  final String
      status; // 'pending', 'approved', 'rejected', 'reschedule_proposal'
  final DateTime? createdAt; // NUEVO CAMPO (Opcional para compatibilidad)

  Appointment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.title,
    this.description = '',
    required this.date,
    required this.status,
    this.createdAt, // Constructor actualizado
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Helper para convertir Timestamps de Firebase a DateTime
    DateTime toDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      return DateTime.now();
    }

    // Helper seguro para createdAt (puede ser null en registros viejos)
    DateTime? toDateTimeNullable(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      return null;
    }

    return Appointment(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? 'Cliente',
      title: json['title'] ?? 'Reunión',
      description: json['description'] ?? '',
      date: toDateTime(json['date']),
      status: json['status'] ?? 'pending',
      createdAt: toDateTimeNullable(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'title': title,
      'description': description,
      'date':
          date.toIso8601String(), // Guardamos como ISO 8601 para consistencia
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
