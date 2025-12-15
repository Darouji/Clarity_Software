// lib/models/client_user.dart

class ClientUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' o 'client'
  final String photoUrl;

  // --- NUEVO: Propiedades de Firma Digital ---
  final String? signatureUrl; // URL de su firma actual
  final bool hasSignatureConfigured; // Helper para saber si ya la configuró

  ClientUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl = '',
    // --- NUEVO ---
    this.signatureUrl,
    this.hasSignatureConfigured = false,
  });

  factory ClientUser.fromJson(Map<String, dynamic> json) {
    return ClientUser(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Usuario',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      photoUrl: json['photoUrl'] ?? '',
      // --- NUEVO ---
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
      // --- NUEVO ---
      'signatureUrl': signatureUrl,
      'hasSignatureConfigured': hasSignatureConfigured,
    };
  }

  // Helper para saber si es admin
  bool get isAdmin => role == 'admin';
}
