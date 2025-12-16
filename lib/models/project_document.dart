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
  final String uploaderId;
  final String uploaderName; // Campo agregado
  final String title;
  final String description;
  final String fileUrl;
  final DocumentType fileType;
  final DocumentStatus status;
  final DateTime uploadDate;
  final String size; // Campo agregado (ej: "1.2 MB")

  // Datos de Firma
  final String? signedByUserId;
  final DateTime? signedAt;
  final String? signedDocumentUrl;

  ProjectDocument({
    required this.id,
    required this.projectId,
    required this.uploaderId,
    required this.uploaderName,
    required this.title,
    this.description = '',
    required this.fileUrl,
    required this.fileType,
    required this.status,
    required this.uploadDate,
    required this.size,
    this.signedByUserId,
    this.signedAt,
    this.signedDocumentUrl,
  });

  // Getter de compatibilidad para que 'doc.name' funcione igual que 'doc.title'
  String get name => title;

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      uploaderId: json['uploaderId'] ?? '',
      uploaderName: json['uploaderName'] ?? 'Desconocido',
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
      size: json['size'] ?? 'Unknown',
      signedByUserId: json['signedByUserId'],
      signedAt: json['signedAt'] != null
          ? DateTime.parse(json['signedAt'])
          : null,
      signedDocumentUrl: json['signedDocumentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileType': fileType.toString(),
      'status': status.toString(),
      'uploadDate': uploadDate.toIso8601String(),
      'size': size,
      'signedByUserId': signedByUserId,
      'signedAt': signedAt?.toIso8601String(),
      'signedDocumentUrl': signedDocumentUrl,
    };
  }
}
