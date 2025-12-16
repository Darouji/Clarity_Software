// lib/services/document_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/project_document.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// STREAM: Obtener documentos de un proyecto en tiempo real
  Stream<List<ProjectDocument>> getDocumentsStream(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('documents')
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ProjectDocument.fromJson(data);
          }).toList();
        });
  }

  /// Guardar un nuevo registro de documento
  // AHORA: Toma solo 1 argumento que contiene toda la info (incluido projectId)
  Future<void> addDocument(ProjectDocument document) async {
    await _db
        .collection('projects')
        .doc(document.projectId)
        .collection('documents')
        .add(document.toJson());
  }

  /// Actualizar estado (ej. al Firmar o Aprobar)
  Future<void> updateDocumentStatus(
    String projectId,
    String docId,
    DocumentStatus status, {
    String? signedUrl, // URL del PDF firmado si aplica
  }) async {
    final Map<String, dynamic> updates = {'status': status.toString()};

    if (signedUrl != null) {
      updates['signedDocumentUrl'] = signedUrl;
      updates['signedAt'] = DateTime.now().toIso8601String();
    }

    await _db
        .collection('projects')
        .doc(projectId)
        .collection('documents')
        .doc(docId)
        .update(updates);
  }

  /// Eliminar documento
  Future<void> deleteDocument(String projectId, String docId) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .collection('documents')
        .doc(docId)
        .delete();
  }
}
