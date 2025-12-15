// lib/services/feedback_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/feedback_message.dart';

class FeedbackNotificationService {
  static final FeedbackNotificationService _instance =
      FeedbackNotificationService._internal();
  factory FeedbackNotificationService() => _instance;
  FeedbackNotificationService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init() async {}

  /// Añade un nuevo mensaje de feedback (AHORA SOPORTA ADJUNTOS Y CITAS)
  Future<void> addFeedback({
    required String projectId,
    required String milestoneTitle,
    required String message,
    required FeedbackType type,
    required String author,
    List<String> attachments = const [], // Nuevo
    MessageCitation? citation, // Nuevo
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
      attachments: attachments,
      citation: citation,
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
        // .orderBy('timestamp', descending: true) // Requiere índice
        .snapshots()
        .map((snapshot) {
          final msgs = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return FeedbackMessage.fromJson(data);
          }).toList();

          msgs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return msgs;
        });
  }

  /// STREAM: Escucha mensajes NO LEÍDOS para el proyecto
  Stream<List<FeedbackMessage>> getUnreadFeedbackStream(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('feedback')
        .where('isRead', isEqualTo: false)
        .where('author', isNotEqualTo: 'Cliente')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return FeedbackMessage.fromJson(data);
          }).toList();
        });
  }

  /// Marca como leídos los mensajes de un hito
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
