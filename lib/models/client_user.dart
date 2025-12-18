// lib/models/client_user.dart

class ClientUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' o 'client'
  final String photoUrl;

  // Nuevos campos requeridos por la UI
  final String? phoneNumber;
  final String? companyName;

  // Propiedades de Firma Digital
  final String? signatureUrl;
  final bool hasSignatureConfigured;

  ClientUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl = '',
    this.phoneNumber,
    this.companyName,
    this.signatureUrl,
    this.hasSignatureConfigured = false,
  });

  // Getter para compatibilidad con el código que busca 'displayName'
  String get displayName => name;

  // Helper para saber si es admin
  bool get isAdmin => role == 'admin';

  factory ClientUser.fromJson(Map<String, dynamic> json) {
    return ClientUser(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Usuario',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      photoUrl: json['photoUrl'] ?? '',
      phoneNumber: json['phoneNumber'],
      companyName: json['companyName'],
      signatureUrl: json['signatureUrl'],
      hasSignatureConfigured: json['hasSignatureConfigured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'companyName': companyName,
      'signatureUrl': signatureUrl,
      'hasSignatureConfigured': hasSignatureConfigured,
    };
  }
}
