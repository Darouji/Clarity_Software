// lib/models/chat_message.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String? imageUrl;
  final String? pdfUrl;
  final bool isSystemMessage;

  // Nuevos campos para "Responder/Citar"
  final String? replyToMessageId;
  final String? replyToMessageText;
  final String? replyToSenderName;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.imageUrl,
    this.pdfUrl,
    this.isSystemMessage = false,
    this.replyToMessageId,
    this.replyToMessageText,
    this.replyToSenderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp, // Firestore lo convertirá a Timestamp
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'isSystemMessage': isSystemMessage,
      'replyToMessageId': replyToMessageId,
      'replyToMessageText': replyToMessageText,
      'replyToSenderName': replyToSenderName,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Desconocido',
      text: map['text'] ?? '',

      // --- CORRECCIÓN CRÍTICA AQUÍ ---
      // Verificamos si es Timestamp (formato Firestore) o int (formato antiguo/milisegundos)
      timestamp: _parseTimestamp(map['timestamp']),

      imageUrl: map['imageUrl'],
      pdfUrl: map['pdfUrl'],
      isSystemMessage: map['isSystemMessage'] ?? false,
      replyToMessageId: map['replyToMessageId'],
      replyToMessageText: map['replyToMessageText'],
      replyToSenderName: map['replyToSenderName'],
    );
  }

  /// Método auxiliar seguro para leer fechas sin crashear
  static DateTime _parseTimestamp(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate(); // Caso normal Firestore
    if (val is int)
      return DateTime.fromMillisecondsSinceEpoch(
          val); // Caso número/milisegundos
    return DateTime.now(); // Fallback por seguridad
  }
}
