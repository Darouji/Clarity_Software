// lib/models/chat_message.dart

enum MessageType { text, image, file, signatureRequest, signatureCompleted }

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content; // Texto del mensaje o URL/Path del archivo
  final MessageType type;
  final DateTime timestamp;
  final bool isMe; // true = Cliente, false = Admin

  // Metadatos opcionales
  final String? replyToMessageId; // ID del mensaje al que se responde
  final String? replyToContent; // Texto visual de la cita
  final String? fileName; // Nombre del archivo (si es documento)
  final String? fileSize; // Peso del archivo (ej. "2.5 MB")

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isMe,
    this.replyToMessageId,
    this.replyToContent,
    this.fileName,
    this.fileSize,
  });

  // Factory para datos de prueba (Mock)
  factory ChatMessage.mock({
    required String id,
    required String content,
    required bool isMe,
    MessageType type = MessageType.text,
    String? replyToContent,
    String? fileName,
  }) {
    return ChatMessage(
      id: id,
      senderId: isMe ? 'me' : 'admin',
      senderName: isMe ? 'Yo' : 'Soporte Clarity',
      content: content,
      type: type,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: isMe,
      replyToContent: replyToContent,
      fileName: fileName,
      fileSize: fileName != null ? '1.5 MB' : null,
    );
  }
}
