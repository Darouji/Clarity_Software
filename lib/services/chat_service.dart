import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de mensajes
  CollectionReference _getChatCollection(String clientId) {
    return _db.collection('chats').doc(clientId).collection('messages');
  }

  // --- ENVIAR MENSAJE ---
  Future<void> sendMessage({
    required String clientId,
    required String text,
    String? imageUrl,
    String? pdfUrl,
    bool isSystemMessage = false,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Crear el modelo correctamente usando los campos que SI existen en tu ChatMessage
    final message = ChatMessage(
      id: '', // Firestore generará esto luego, o podemos dejarlo vacío aquí
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'Usuario',
      text: text, // Asumiendo que tu modelo usa 'text' o 'message'
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      pdfUrl: pdfUrl,
      isSystemMessage: isSystemMessage,
    );

    // Usamos toJson() o toMap() según lo que tengas en tu modelo.
    // Si tu modelo usa 'message' en vez de 'text' para el contenido, ajusta esto.
    await _getChatCollection(clientId).add(message.toMap());

    // Actualizar metadata del chat
    await _db.collection('chats').doc(clientId).set({
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
      'clientId': clientId,
    }, SetOptions(merge: true));
  }

  // --- OBTENER MENSAJES (STREAM) ---
  Stream<List<ChatMessage>> getMessages(String clientId) {
    return _getChatCollection(clientId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Aseguramos pasar el ID del documento
        return ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
