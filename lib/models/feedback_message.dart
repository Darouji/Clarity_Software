// lib/models/feedback_message.dart

enum FeedbackType { approval, changeRequest }

class FeedbackMessage {
  final String id;
  final String projectId;
  final String milestoneTitle;
  final String message;
  final FeedbackType type;
  final DateTime timestamp;
  final String author; // Quién lo envió (ej. "Cliente" o "Admin")
  bool isRead;

  FeedbackMessage({
    required this.id,
    required this.projectId,
    required this.milestoneTitle,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.author,
    this.isRead = false,
  });

  // Métodos de serialización JSON para SharedPreferences
  factory FeedbackMessage.fromJson(Map<String, dynamic> json) {
    return FeedbackMessage(
      id: json['id'],
      projectId: json['projectId'],
      milestoneTitle: json['milestoneTitle'],
      message: json['message'],
      type: FeedbackType.values.firstWhere((e) => e.toString() == json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      author: json['author'],
      isRead: json['isRead'],
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
    };
  }
}
