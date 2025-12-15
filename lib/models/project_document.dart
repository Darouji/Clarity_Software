// lib/models/project_document.dart

enum DocumentType { pdf, image, word, other }

enum DocumentStatus {
  pendingSignature,
  signed,
  approved,
  rejected,
  informational,
}

class ProjectDocument {
  final String id;
  final String projectId;
  final String uploaderId; // ID del usuario que subió el archivo
  final String title;
  final String description;
  final String fileUrl; // URL de descarga en Firebase Storage
  final DocumentType fileType;
  final DocumentStatus status;
  final DateTime uploadDate;

  // Datos de Firma (opcionales, solo si está firmado)
  final String? signedByUserId;
  final DateTime? signedAt;
  final String?
  signedDocumentUrl; // URL del documento ya firmado (copia sellada)

  ProjectDocument({
    required this.id,
    required this.projectId,
    required this.uploaderId,
    required this.title,
    this.description = '',
    required this.fileUrl,
    required this.fileType,
    required this.status,
    required this.uploadDate,
    this.signedByUserId,
    this.signedAt,
    this.signedDocumentUrl,
  });

  // Convertir JSON a Objeto
  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      uploaderId: json['uploaderId'] ?? '',
      title: json['title'] ?? 'Documento sin título',
      description: json['description'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: DocumentType.values.firstWhere(
        (e) => e.toString() == json['fileType'],
        orElse: () => DocumentType.other,
      ),
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => DocumentStatus.informational,
      ),
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'])
          : DateTime.now(),
      signedByUserId: json['signedByUserId'],
      signedAt: json['signedAt'] != null
          ? DateTime.parse(json['signedAt'])
          : null,
      signedDocumentUrl: json['signedDocumentUrl'],
    );
  }

  // Convertir Objeto a JSON (para guardar en Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'uploaderId': uploaderId,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileType': fileType.toString(),
      'status': status.toString(),
      'uploadDate': uploadDate.toIso8601String(),
      'signedByUserId': signedByUserId,
      'signedAt': signedAt?.toIso8601String(),
      'signedDocumentUrl': signedDocumentUrl,
    };
  }
}
