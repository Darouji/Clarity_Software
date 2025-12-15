// lib/models/digital_signature.dart

class DigitalSignature {
  final String userId;
  final String signatureImageUrl; // La imagen PNG transparente lista para usar
  final List<dynamic>?
  strokePoints; // Puntos crudos (raw data) si se necesita reeditar
  final DateTime createdAt;

  DigitalSignature({
    required this.userId,
    required this.signatureImageUrl,
    this.strokePoints,
    required this.createdAt,
  });

  factory DigitalSignature.fromJson(Map<String, dynamic> json) {
    return DigitalSignature(
      userId: json['userId'] ?? '',
      signatureImageUrl: json['signatureImageUrl'] ?? '',
      strokePoints: json['strokePoints'], // Lista de puntos
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'signatureImageUrl': signatureImageUrl,
      'strokePoints': strokePoints,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
