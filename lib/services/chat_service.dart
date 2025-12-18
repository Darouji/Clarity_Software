// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de mensajes por CLIENTE
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
    ChatMessage? replyTo,
  }) async {
    try {
      final currentUser = _auth.currentUser;

      // Validación: Si NO es mensaje de sistema y NO hay usuario, error.
      if (!isSystemMessage && currentUser == null) {
        throw Exception("No hay usuario logueado para enviar el mensaje.");
      }

      final String senderId =
          isSystemMessage ? 'system_admin' : currentUser!.uid;
      final String senderName = isSystemMessage
          ? 'Clarity Admin'
          : (currentUser?.displayName ?? 'Usuario');

      final message = ChatMessage(
        id: '', // Se genera automático al insertar
        senderId: senderId,
        senderName: senderName,
        text: text,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
        pdfUrl: pdfUrl,
        isSystemMessage: isSystemMessage,
        replyToMessageId: replyTo?.id,
        replyToMessageText: replyTo?.text,
        replyToSenderName: replyTo?.senderName,
      );

      // Guardar mensaje
      await _getChatCollection(clientId).add(message.toMap());

      // Actualizar metadata del chat (para la lista de chats del admin)
      await _db.collection('chats').doc(clientId).set({
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
        'clientId': clientId,
        // Si escribe el cliente real, actualizamos su nombre en la metadata
        if (!isSystemMessage) 'clientName': senderName,
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Error enviando mensaje: $e");
      rethrow; // Re-lanzar para que la UI se entere
    }
  }

  // --- OBTENER MENSAJES (STREAM) ---
  Stream<List<ChatMessage>> getMessages(String clientId) {
    return _getChatCollection(clientId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatMessage.fromMap(data, doc.id);
      }).toList();
    });
  }

  // --- ASEGURAR BIENVENIDA AUTOMÁTICA ---
  Future<void> ensureWelcomeMessage(String clientId) async {
    try {
      final snapshot = await _getChatCollection(clientId).limit(1).get();

      // Si la colección está vacía, insertamos el mensaje de sistema
      if (snapshot.docs.isEmpty) {
        print("📢 Chat vacío. Insertando mensaje de bienvenida...");

        // Intentamos obtener nombre del cliente para personalizar
        String greetingName = "Cliente";
        try {
          final userDoc = await _db.collection('users').doc(clientId).get();
          if (userDoc.exists && userDoc.data()!.containsKey('name')) {
            greetingName = userDoc.get('name');
          }
        } catch (_) {}

        await sendMessage(
          clientId: clientId,
          text:
              "Hola $greetingName, bienvenido a Clarity Software. Este es tu canal directo con administración. ¿En qué podemos ayudarte?",
          isSystemMessage: true,
        );
      }
    } catch (e) {
      print("❌ Error en bienvenida automática: $e");
    }
  }
}
