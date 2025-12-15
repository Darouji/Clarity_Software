// lib/widgets/chat_widget.dart
import 'dart:io';
import 'package:clarity_software/models/feedback_message.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/models/project_document.dart';
import 'package:clarity_software/services/document_service.dart';
import 'package:clarity_software/services/feedback_notification_service.dart';
import 'package:clarity_software/services/storage_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatWidget extends StatefulWidget {
  final Project project;
  final String milestoneTitle;

  const ChatWidget({
    super.key,
    required this.project,
    required this.milestoneTitle,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final FeedbackNotificationService _chatService =
      FeedbackNotificationService();
  final StorageService _storageService = StorageService();
  final DocumentService _documentService = DocumentService();

  bool _isSending = false;

  // Estado para la "Cita" actual (lo que se está respondiendo)
  MessageCitation? _activeCitation;

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty && _activeCitation == null) return;

    setState(() => _isSending = true);

    try {
      await _chatService.addFeedback(
        projectId: widget.project.id,
        milestoneTitle: widget.milestoneTitle,
        message: _controller.text.trim(),
        type: FeedbackType.general,
        author: 'Cliente', // En una app real, usar AuthService.currentUser.name
        citation: _activeCitation,
      );

      _controller.clear();
      setState(() => _activeCitation = null); // Limpiar cita después de enviar
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // --- MENÚ DE ADJUNTOS Y CITAS ---
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.description, color: AppColors.cyberBlue),
            title: const Text(
              'Citar Documento',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDocumentPicker();
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag, color: AppColors.accentMagenta),
            title: const Text(
              'Citar Hito',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _showMilestonePicker();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.cloud_upload,
              color: AppColors.accentGreen,
            ),
            title: const Text(
              'Subir Archivo',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _uploadFile();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFile() async {
    // Lógica simplificada: Sube archivo y envía mensaje automático con el link
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _isSending = true);
      try {
        final file = File(result.files.single.path!);
        final url = await _storageService.uploadFile(
          file,
          'chat/${widget.project.id}',
        );

        await _chatService.addFeedback(
          projectId: widget.project.id,
          milestoneTitle: widget.milestoneTitle,
          message: '📎 Archivo adjunto: ${result.files.single.name}',
          type: FeedbackType.general,
          author: 'Cliente',
          attachments: [url],
        );
      } finally {
        if (mounted) setState(() => _isSending = false);
      }
    }
  }

  void _showDocumentPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Seleccionar Documento',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<List<ProjectDocument>>(
            stream: _documentService.getDocumentsStream(widget.project.id),
            builder: (context, snapshot) {
              final docs = snapshot.data ?? [];
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return ListTile(
                    title: Text(
                      doc.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      doc.status.toString().split('.').last,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    onTap: () {
                      setState(() {
                        _activeCitation = MessageCitation(
                          type: CitationType.document,
                          referenceId: doc.id,
                          previewData: doc.title,
                        );
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMilestonePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Seleccionar Hito',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.project.milestones.length,
            itemBuilder: (context, index) {
              final m = widget.project.milestones[index];
              return ListTile(
                title: Text(
                  m.title,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _activeCitation = MessageCitation(
                      type: CitationType.milestone,
                      referenceId: m.title, // Usamos título como ID simple
                      previewData:
                          'Hito: ${m.title} (${(m.progress * 100).toInt()}%)',
                    );
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- LISTA DE MENSAJES ---
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              0, // El StreamBuilder externo manejará esto, aquí solo mostramos la estructura interna
          itemBuilder: (context, index) => const SizedBox(),
        ),
        // Nota: Este widget está diseñado para ser hijo de un StreamBuilder en KanbanBoard.
        // Para simplificar, asumiremos que KanbanBoard renderiza la lista y este widget solo maneja el INPUT.
        // Pero para cumplir con "Chat Completo", vamos a incluir la lógica de renderizado de burbuja aquí abajo.

        // --- ÁREA DE INPUT ---
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBlack,
            border: Border(
              top: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
            ),
          ),
          child: Column(
            children: [
              // Vista previa de la Cita Activa
              if (_activeCitation != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyberBlue.withValues(alpha: 0.1),
                    border: const Border(
                      left: BorderSide(color: AppColors.cyberBlue, width: 3),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.format_quote,
                        color: AppColors.cyberBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _activeCitation!.previewData,
                          style: const TextStyle(
                            color: AppColors.cyberBlue,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(() => _activeCitation = null),
                      ),
                    ],
                  ),
                ),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: AppColors.grey),
                    onPressed: _showAttachmentMenu,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: AppColors.cyberBlue),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- WIDGET AUXILIAR: Burbuja de Mensaje ---
// Usar este widget dentro del StreamBuilder del Kanban o pantalla de Chat
class ChatBubble extends StatelessWidget {
  final FeedbackMessage message;
  final bool isMe; // Si soy el autor

  const ChatBubble({super.key, required this.message, required this.isMe});

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isMe
        ? AppColors.cyberBlue.withValues(alpha: 0.2)
        : AppColors.cardBackground;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
      bottomRight: isMe ? Radius.zero : const Radius.circular(12),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bgColor, borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Mostrar Cita si existe
              if (message.citation != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    border: const Border(
                      left: BorderSide(color: Colors.white54, width: 3),
                    ),
                  ),
                  child: Text(
                    message.citation!.previewData,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // 2. Mostrar Texto
              Text(
                message.message,
                style: const TextStyle(color: Colors.white),
              ),

              // 3. Mostrar Adjuntos
              if (message.attachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 8,
                    children: message.attachments.map((url) {
                      return GestureDetector(
                        onTap: () => _launchURL(url),
                        child: const Chip(
                          avatar: Icon(Icons.attach_file, size: 16),
                          label: Text(
                            'Ver Archivo',
                            style: TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.black26,
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // 4. Fecha
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
