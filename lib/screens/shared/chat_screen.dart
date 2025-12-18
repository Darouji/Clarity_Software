// lib/screens/shared/chat_screen.dart
import 'package:clarity_software/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/models/chat_message.dart';
import 'package:clarity_software/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String clientId;
  final String title;

  const ChatScreen({
    super.key,
    required this.clientId,
    this.title = 'Chat', // Título limpio por defecto
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    _messageController.clear();
    await _chatService.sendMessage(clientId: widget.clientId, text: text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.clientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.cyberBlue));

                // MENSAJE DE BIENVENIDA SI ESTÁ VACÍO
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return FutureBuilder(
                    future: _userService
                        .getUserName(_currentUserId), // Obtener nombre
                    builder: (context, nameSnapshot) {
                      final name = nameSnapshot.data ?? "Usuario";
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            "Hola $name, bienvenido al chat, el medio de comunicación directa con los administradores.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                                height: 1.5),
                          ),
                        ),
                      );
                    },
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(
                        msg, msg.senderId == _currentUserId);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    if (msg.isSystemMessage) {
      return Center(
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(msg.text,
                  style: const TextStyle(
                      color: AppColors.cyberBlue, fontSize: 12))));
    }
    return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isMe ? AppColors.cyberBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft:
                        isMe ? const Radius.circular(12) : Radius.circular(0),
                    bottomRight:
                        isMe ? Radius.circular(0) : const Radius.circular(12))),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!isMe)
                Text(msg.senderName,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              Text(msg.text,
                  style: TextStyle(color: isMe ? Colors.black : Colors.white)),
              const SizedBox(height: 4),
              Text(DateFormat('HH:mm').format(msg.timestamp),
                  style: TextStyle(
                      color: isMe ? Colors.black54 : Colors.white30,
                      fontSize: 10))
            ])));
  }

  Widget _buildInputArea() {
    return Container(
        color: AppColors.cardBackground,
        child: SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  IconButton(
                      icon: const Icon(Icons.image, color: AppColors.cyberBlue),
                      onPressed: () {}),
                  Expanded(
                      child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              hintText: "Escribe un mensaje...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none))),
                  IconButton(
                      icon: const Icon(Icons.send, color: AppColors.cyberBlue),
                      onPressed: _sendMessage)
                ]))));
  }
}
