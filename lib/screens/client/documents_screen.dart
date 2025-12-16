// lib/screens/client/documents_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/models/project_document.dart';
import 'package:clarity_software/services/document_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DocumentsScreen extends StatefulWidget {
  final Project project;

  const DocumentsScreen({super.key, required this.project});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentService _documentService = DocumentService();

  Future<void> _handleUpload() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulando subida de archivo...'),
        backgroundColor: AppColors.cyberBlue,
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // CORRECCIÓN: Llamada con 1 solo argumento (el objeto documento)
    await _documentService.addDocument(
      ProjectDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: widget.project.id,
        uploaderId:
            'current_user_id', // En prod usar AuthService().currentUser.id
        uploaderName: 'Yo',
        title: 'Nuevo Documento.pdf',
        description: 'Documento subido desde la app',
        fileUrl: 'http://example.com',
        fileType: DocumentType.pdf,
        status: DocumentStatus.informational,
        uploadDate: DateTime.now(),
        size: '1.2 MB',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor: AppColors.appBarBackground.withValues(
                alpha: 0.8,
              ),
              elevation: 0,
              title: const Text(
                'Documentación',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: const BackButton(color: Colors.white),
              actions: const [
                GlobalAppBarMenu(currentScreen: AppScreen.projectDetails),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<ProjectDocument>>(
        stream: _documentService.getDocumentsStream(widget.project.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyberBlue),
            );
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay documentos aún.',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _handleUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Subir Primer Archivo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyberBlue,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: NeonCard(
                  glowColor: AppColors.accentPurple.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.filePdf,
                        color: AppColors.accentRed,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${doc.size} • ${doc.uploaderName} • ${_formatDate(doc.uploadDate)}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.download_rounded,
                          color: AppColors.cyberBlue,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Descargando archivo...'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        onPressed: _handleUpload,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
