// lib/models/feedback_message.dart

enum FeedbackType { approval, changeRequest, general }

enum CitationType { document, milestone, message }

// Clase auxiliar para manejar la "Cita" o referencia
class MessageCitation {
  final CitationType type;
  final String referenceId; // ID del documento/hito citado
  final String previewData; // Título del doc o texto del mensaje

  MessageCitation({
    required this.type,
    required this.referenceId,
    required this.previewData,
  });

  factory MessageCitation.fromJson(Map<String, dynamic> json) {
    return MessageCitation(
      type: CitationType.values.firstWhere((e) => e.toString() == json['type']),
      referenceId: json['referenceId'] ?? '',
      previewData: json['previewData'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'referenceId': referenceId,
      'previewData': previewData,
    };
  }
}

class FeedbackMessage {
  final String id;
  final String projectId;
  final String milestoneTitle;
  final String message;
  final FeedbackType type;
  final DateTime timestamp;
  final String author;
  bool isRead;

  // --- NUEVOS CAMPOS ---
  final List<String> attachments; // Lista de URLs de imágenes/PDFs
  final MessageCitation? citation; // La referencia citada (opcional)

  FeedbackMessage({
    required this.id,
    required this.projectId,
    required this.milestoneTitle,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.author,
    this.isRead = false,
    this.attachments = const [],
    this.citation,
  });

  factory FeedbackMessage.fromJson(Map<String, dynamic> json) {
    return FeedbackMessage(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      milestoneTitle: json['milestoneTitle'] ?? '',
      message: json['message'] ?? '',
      type: FeedbackType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => FeedbackType.general,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      author: json['author'] ?? 'Desconocido',
      isRead: json['isRead'] ?? false,
      attachments: List<String>.from(json['attachments'] ?? []),
      citation: json['citation'] != null
          ? MessageCitation.fromJson(json['citation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'milestoneTitle': milestoneTitle,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'author': author,
      'isRead': isRead,
      'attachments': attachments,
      'citation': citation?.toJson(),
    };
  }
}
