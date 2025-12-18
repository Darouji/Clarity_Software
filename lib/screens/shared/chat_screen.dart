// lib/screens/shared/chat_screen.dart
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
    this.title = 'Chat',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Estado para "Responder/Citar"
  ChatMessage? _replyingTo;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tryCreateWelcomeMessage();
  }

  /// Intenta crear el mensaje en BD, pero no bloquea la UI si falla
  void _tryCreateWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _chatService.ensureWelcomeMessage(widget.clientId);
      } catch (e) {
        debugPrint("Advertencia: No se pudo guardar bienvenida en BD: $e");
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    final replyTo = _replyingTo; // Copia local

    // Limpieza inmediata de UI
    _messageController.clear();
    setState(() => _replyingTo = null);

    try {
      await _chatService.sendMessage(
        clientId: widget.clientId,
        text: text,
        replyTo: replyTo,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al enviar: $e"),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _startReply(ChatMessage message) {
    setState(() => _replyingTo = message);
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        // Eliminado el botón de borrar. El cliente no debe tener esta opción.
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.clientId),
              builder: (context, snapshot) {
                // 1. Cargando
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.cyberBlue));
                }

                // 2. Error en el stream
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text("Error de conexión: ${snapshot.error}",
                          style: const TextStyle(color: AppColors.accentRed),
                          textAlign: TextAlign.center),
                    ),
                  );
                }

                // 3. Datos
                final messages = snapshot.data ?? [];

                // SI ESTÁ VACÍO: Mostramos la bienvenida "Visual"
                if (messages.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSystemMessageBubble(
                          "Hola, bienvenido al chat. Este es tu canal directo con administración. Escribe tu consulta."),
                    ],
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _currentUserId;

                    return Dismissible(
                      key: Key(msg.id),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (_) async {
                        _startReply(msg);
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        color: Colors.transparent,
                        child:
                            const Icon(Icons.reply, color: AppColors.cyberBlue),
                      ),
                      child: _buildMessageBubble(msg, isMe),
                    );
                  },
                );
              },
            ),
          ),
          _buildReplyPreview(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSystemMessageBubble(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline,
                color: AppColors.cyberBlue, size: 16),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    if (msg.isSystemMessage) {
      return _buildSystemMessageBubble(msg.text);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(msg.senderName,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.cyberBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft:
                      isMe ? const Radius.circular(12) : Radius.circular(0),
                  bottomRight:
                      isMe ? Radius.circular(0) : const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.replyToMessageId != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                            alpha: 0.2), // Corrección para Flutter moderno
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                            left: BorderSide(
                                color:
                                    isMe ? Colors.white : AppColors.cyberBlue,
                                width: 3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.replyToSenderName ?? 'Usuario',
                              style: TextStyle(
                                  color:
                                      isMe ? Colors.white : AppColors.cyberBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          Text(msg.replyToMessageText ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.white60,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  Text(msg.text,
                      style:
                          TextStyle(color: isMe ? Colors.black : Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 2),
              child: Text(
                DateFormat('HH:mm').format(msg.timestamp),
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingTo == null) return const SizedBox.shrink();
    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.reply, color: AppColors.cyberBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Respondiendo a ${_replyingTo!.senderName}",
                    style: const TextStyle(
                        color: AppColors.cyberBlue,
                        fontWeight: FontWeight.bold)),
                Text(_replyingTo!.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _cancelReply,
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: AppColors.cardBackground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.cyberBlue),
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Escribe un mensaje...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.cyberBlue),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
