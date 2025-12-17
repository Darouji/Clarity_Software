class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text; // Asegúrate que se llame 'text'
  final DateTime timestamp;
  final String? imageUrl;
  final String? pdfUrl;
  final bool isSystemMessage; // Asegúrate que exista este campo

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.imageUrl,
    this.pdfUrl,
    this.isSystemMessage = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'isSystemMessage': isSystemMessage,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Usuario',
      text: map['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      imageUrl: map['imageUrl'],
      pdfUrl: map['pdfUrl'],
      isSystemMessage: map['isSystemMessage'] ?? false,
    );
  }
}
