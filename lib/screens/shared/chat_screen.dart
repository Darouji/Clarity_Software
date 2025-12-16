// lib/screens/shared/chat_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:clarity_software/models/chat_message.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/screens/shared/signature_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatScreen extends StatefulWidget {
  final String? targetChatId;
  final String? chatTitle;
  final String? initialMessage;

  const ChatScreen({
    super.key,
    this.targetChatId,
    this.chatTitle,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  late TextEditingController _textController;
  final ScrollController _scrollController = ScrollController();

  ChatMessage? _replyingTo;

  late String _currentUserId;
  late bool _isAdmin;
  bool _isUploading = false;

  final List<ChatMessage> _messages = [
    ChatMessage.mock(
      id: '1',
      content: '¡Hola! Bienvenido a tu canal de soporte directo.',
      isMe: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialMessage ?? '');
    _initializeChat();
  }

  void _initializeChat() {
    final user = _authService.currentUser;
    if (user != null) {
      _currentUserId = user.id;
      _isAdmin = user.isAdmin;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      senderName: _isAdmin ? 'Soporte' : 'Yo',
      content: _textController.text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isMe: true,
      replyToMessageId: _replyingTo?.id,
      replyToContent: _replyingTo?.content,
    );

    setState(() {
      _messages.add(newMessage);
      _textController.clear();
      _replyingTo = null;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _uploadFileToFirebase(
          File(image.path), MessageType.image, image.name);
    }
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      await _uploadFileToFirebase(
          file, MessageType.file, result.files.single.name);
    }
  }

  Future<void> _uploadFileToFirebase(
      File file, MessageType type, String fileName) async {
    setState(() => _isUploading = true);
    try {
      String path =
          'chat_uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref(path).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      final newMessage = ChatMessage.mock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: downloadUrl,
        isMe: true,
        type: type,
        fileName: fileName,
      );

      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleSignatureProcess() async {
    final dynamic signed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignatureScreen()),
    );

    if (signed == true) {
      final signMessage = ChatMessage.mock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Documento firmado y enviado correctamente.',
        isMe: true,
        type: MessageType.signatureCompleted,
        fileName: 'Contrato_Firmado.pdf',
      );
      setState(() => _messages.add(signMessage));
      _scrollToBottom();
    }
  }

  void _handleAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: AppColors.cyberBlue.withValues(alpha: 0.3)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAttachmentOption(
              icon: Icons.image,
              label: 'Galería / Fotos',
              color: AppColors.accentMagenta,
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage();
              },
            ),
            const SizedBox(height: 15),
            _buildAttachmentOption(
              icon: Icons.insert_drive_file,
              label: 'Documento / Archivo',
              color: AppColors.cyberBlue,
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadFile();
              },
            ),
            const SizedBox(height: 15),
            _buildAttachmentOption(
              icon: Icons.edit_document,
              label: _isAdmin ? 'Solicitar Firma' : 'Firmar Documento',
              color: AppColors.accentGreen,
              onTap: () {
                Navigator.pop(context);
                if (_isAdmin) {
                  _simulateSend(MessageType.signatureRequest,
                      'Por favor firme este documento.');
                } else {
                  _handleSignatureProcess();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _simulateSend(MessageType type, String content) {
    final newMessage = ChatMessage.mock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isMe: true,
      type: type,
      fileName: type == MessageType.file ? content : null,
    );
    setState(() => _messages.add(newMessage));
    _scrollToBottom();
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingTo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        border: Border(
          top: BorderSide(color: AppColors.cyberBlue.withValues(alpha: 0.3)),
          left: const BorderSide(color: AppColors.cyberBlue, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Respondiendo a ${_replyingTo!.senderName}',
                  style: const TextStyle(
                    color: AppColors.cyberBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyingTo!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final bool isMe = msg.isMe;
    final Alignment alignment =
        isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isMe
        ? AppColors.cyberBlue.withValues(alpha: 0.2)
        : AppColors.cardBackground;
    final Color borderColor = isMe ? AppColors.cyberBlue : Colors.white24;

    return Dismissible(
      key: Key(msg.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        setState(() => _replyingTo = msg);
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.reply, color: AppColors.cyberBlue),
      ),
      child: Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (msg.replyToContent != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                        left: BorderSide(color: Colors.white54, width: 3)),
                  ),
                  child: Text(
                    msg.replyToContent!,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft:
                        isMe ? const Radius.circular(16) : Radius.circular(0),
                    bottomRight:
                        isMe ? Radius.circular(0) : const Radius.circular(16),
                  ),
                  border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      Text(
                        msg.senderName,
                        style: const TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    _buildMessageContent(msg),
                    const SizedBox(height: 4),
                    Text(
                      '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  msg.content,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white30,
                      size: 50),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ],
        );
      case MessageType.file:
      case MessageType.signatureCompleted:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (msg.type == MessageType.signatureCompleted
                        ? AppColors.accentGreen
                        : AppColors.accentMagenta)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                  msg.type == MessageType.signatureCompleted
                      ? Icons.verified
                      : Icons.insert_drive_file,
                  color: msg.type == MessageType.signatureCompleted
                      ? AppColors.accentGreen
                      : AppColors.accentMagenta),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.fileName ?? 'Archivo',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Toca para descargar',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        );
      case MessageType.signatureRequest:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accentGreen),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.accentGreen.withValues(alpha: 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.draw, color: AppColors.accentGreen, size: 20),
                  SizedBox(width: 8),
                  Text('Firma Requerida',
                      style: TextStyle(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(msg.content, style: const TextStyle(color: Colors.white70)),
              if (!msg.isMe && !_isAdmin) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _handleSignatureProcess,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('FIRMAR AHORA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                ),
              ],
            ],
          ),
        );
      default:
        return Text(
          msg.content,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor:
                  AppColors.appBarBackground.withValues(alpha: 0.8),
              elevation: 0,
              leading: const BackButton(color: Colors.white),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chatTitle ?? 'Chat',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const Text('En línea',
                      style:
                          TextStyle(color: AppColors.cyberBlue, fontSize: 12)),
                ],
              ),
              actions: const [
                GlobalAppBarMenu(currentScreen: AppScreen.overview),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(_messages[index]),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReplyPreview(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      border: Border(
                          top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1))),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: AppColors.cyberBlue),
                            onPressed: _handleAttachmentMenu,
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: _textController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Escribe un mensaje...',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.cyberBlue,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send,
                                  color: Colors.white, size: 20),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.cyberBlue),
              ),
            ),
        ],
      ),
    );
  }
}
