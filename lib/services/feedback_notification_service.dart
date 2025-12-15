// lib/services/feedback_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/feedback_message.dart';

class FeedbackNotificationService {
  static final FeedbackNotificationService _instance =
      FeedbackNotificationService._internal();
  factory FeedbackNotificationService() => _instance;
  FeedbackNotificationService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ya no necesitamos init() con SharedPreferences, pero lo dejamos vacío
  // por compatibilidad con el main.dart existente.
  Future<void> init() async {}

  /// Añade un nuevo mensaje de feedback a la subcolección del proyecto
  Future<void> addFeedback({
    required String projectId,
    required String milestoneTitle,
    required String message,
    required FeedbackType type,
    required String author,
  }) async {
    final newMessage = FeedbackMessage(
      id: '', // Firestore generará el ID
      projectId: projectId,
      milestoneTitle: milestoneTitle,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      author: author,
      isRead: false,
    );

    await _db
        .collection('projects')
        .doc(projectId)
        .collection('feedback')
        .add(newMessage.toJson());
  }

  /// STREAM: Escucha los mensajes de un hito en tiempo real
  Stream<List<FeedbackMessage>> getFeedbackStream(
    String projectId,
    String milestoneTitle,
  ) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('feedback')
        .where('milestoneTitle', isEqualTo: milestoneTitle)
        // Ordenamos por fecha descendente (más nuevos primero)
        // Nota: Si Firebase pide crear un índice, verás el link en la consola de debug
        // .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final msgs = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Asegurar ID
            return FeedbackMessage.fromJson(data);
          }).toList();

          // Ordenamiento manual por si falta el índice compuesto en Firestore
          msgs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return msgs;
        });
  }

  /// STREAM: Escucha mensajes NO LEÍDOS para el proyecto (Iconos de notificación)
  Stream<List<FeedbackMessage>> getUnreadFeedbackStream(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('feedback')
        .where('isRead', isEqualTo: false)
        .where(
          'author',
          isNotEqualTo: 'Cliente',
        ) // Solo lo que escribe el Admin
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return FeedbackMessage.fromJson(data);
          }).toList();
        });
  }

  /// Marca como leídos los mensajes de un hito (Batch update)
  Future<void> markMilestoneFeedbackAsRead(
    String projectId,
    String milestoneTitle,
  ) async {
    final snapshot = await _db
        .collection('projects')
        .doc(projectId)
        .collection('feedback')
        .where('milestoneTitle', isEqualTo: milestoneTitle)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }
}
