// lib/models/appointment.dart

class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final String title;
  final String description;
  final DateTime date;
  final String status; // 'pending', 'approved', 'rejected'

  Appointment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.title,
    this.description = '',
    required this.date,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? 'Cliente',
      title: json['title'] ?? 'Cita General',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
