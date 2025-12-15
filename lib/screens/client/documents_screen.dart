// lib/screens/client/documents_screen.dart
import 'dart:io';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/models/project_document.dart';
import 'package:clarity_software/screens/client/signature_setup_screen.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/services/document_service.dart';
import 'package:clarity_software/services/storage_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:file_picker/file_picker.dart';
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
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  int _selectedFilterIndex = 0;
  bool _isUploading = false;

  // Helper para saber si es admin
  bool get _isAdmin => _authService.currentUser?.isAdmin ?? false;

  IconData _getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return FontAwesomeIcons.filePdf;
      case DocumentType.image:
        return FontAwesomeIcons.solidImage;
      case DocumentType.word:
        return FontAwesomeIcons.fileWord;
      default:
        return FontAwesomeIcons.file;
    }
  }

  Color _getColorForStatus(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pendingSignature:
        return AppColors.accentOrange;
      case DocumentStatus.signed:
      case DocumentStatus.approved:
        return AppColors.accentGreen;
      case DocumentStatus.rejected:
        return AppColors.accentRed;
      default:
        return AppColors.cyberBlue;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pendingSignature:
        return 'Firma Pendiente';
      case DocumentStatus.signed:
        return 'Firmado';
      case DocumentStatus.approved:
        return 'Aprobado';
      case DocumentStatus.rejected:
        return 'Rechazado';
      case DocumentStatus.informational:
        return 'Informativo';
    }
  }

  // --- LÓGICA DE SUBIDA UNIVERSAL ---
  Future<void> _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);

      try {
        final File file = File(result.files.single.path!);
        final String fileName = result.files.single.name;

        // 1. Determinar tipo
        DocumentType type = DocumentType.other;
        if (fileName.toLowerCase().endsWith('.pdf')) {
          type = DocumentType.pdf;
        } else if (fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg') ||
            fileName.toLowerCase().endsWith('.png')) {
          type = DocumentType.image;
        } else if (fileName.toLowerCase().endsWith('.doc') ||
            fileName.toLowerCase().endsWith('.docx')) {
          type = DocumentType.word;
        }

        // 2. Subir a Storage
        final String downloadUrl = await _storageService.uploadFile(
          file,
          'projects/${widget.project.id}/documents',
        );

        // 3. Determinar Estado Automático según Rol
        // Admin -> Sube contratos -> Requiere Firma
        // Cliente -> Sube fotos/evidencia -> Informativo
        final DocumentStatus initialStatus = _isAdmin
            ? DocumentStatus.pendingSignature
            : DocumentStatus.informational;

        final String description = _isAdmin
            ? 'Documento oficial subido por Admin'
            : 'Evidencia/Archivo subido por Cliente';

        // 4. Crear registro en Firestore
        final newDoc = ProjectDocument(
          id: '', // Se genera auto
          projectId: widget.project.id,
          uploaderId: _authService.currentUser!.id,
          title: fileName,
          description: description,
          fileUrl: downloadUrl,
          fileType: type,
          status: initialStatus,
          uploadDate: DateTime.now(),
        );

        await _documentService.addDocument(newDoc);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo subido correctamente'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  List<ProjectDocument> _filterDocuments(List<ProjectDocument> allDocs) {
    if (_selectedFilterIndex == 0) return allDocs;
    if (_selectedFilterIndex == 1) {
      return allDocs
          .where((d) => d.status == DocumentStatus.pendingSignature)
          .toList();
    }
    if (_selectedFilterIndex == 2) {
      return allDocs
          .where(
            (d) =>
                d.status == DocumentStatus.signed ||
                d.status == DocumentStatus.approved,
          )
          .toList();
    }
    return allDocs;
  }

  void _handleDocumentTap(ProjectDocument doc) {
    // Lógica para Clientes: Firmar si es necesario
    if (!_isAdmin) {
      if (doc.status == DocumentStatus.pendingSignature) {
        final user = _authService.currentUser;
        if (user != null && !user.hasSignatureConfigured) {
          _showConfigureSignatureDialog();
        } else {
          _showSignConfirmationDialog(doc);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abriendo visualizador...')),
        );
      }
    } else {
      // Lógica para Admin: Ver detalles
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${doc.title} (${_getStatusText(doc.status)})'),
          backgroundColor: AppColors.cardBlack,
        ),
      );
    }
  }

  void _showConfigureSignatureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Firma no configurada',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Debes configurar tu firma digital primero.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyberBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignatureSetupScreen(),
                ),
              );
            },
            child: const Text(
              'Configurar',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignConfirmationDialog(ProjectDocument doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Firmar Documento',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Se estampará tu firma digital en este documento.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _performSign(doc);
            },
            icon: const Icon(Icons.edit_document, color: Colors.black),
            label: const Text('FIRMAR', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _performSign(ProjectDocument doc) async {
    try {
      final user = _authService.currentUser!;
      await _documentService.updateDocumentStatus(
        widget.project.id,
        doc.id,
        DocumentStatus.signed,
        signedUrl: user.signatureUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firmado correctamente'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildFilterChip(String label, int index, Color color) {
    final bool isSelected = _selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) =>
            setState(() => _selectedFilterIndex = selected ? index : 0),
        selectedColor: color,
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? color : AppColors.grey.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Docs: ${widget.project.name}',
          style: const TextStyle(fontSize: 18),
        ),
        actions: const [
          GlobalAppBarMenu(currentScreen: AppScreen.projectDetails),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            color: AppColors.primaryBackground,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', 0, AppColors.cyberBlue),
                  _buildFilterChip('Por Firmar', 1, AppColors.accentOrange),
                  _buildFilterChip('Listos', 2, AppColors.accentGreen),
                ],
              ),
            ),
          ),
          if (_isUploading)
            const LinearProgressIndicator(color: AppColors.accentMagenta),
          Expanded(
            child: StreamBuilder<List<ProjectDocument>>(
              stream: _documentService.getDocumentsStream(widget.project.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.cyberBlue,
                    ),
                  );
                }

                final allDocs = snapshot.data ?? [];
                final docs = _filterDocuments(allDocs);

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay documentos.',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final statusColor = _getColorForStatus(doc.status);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: NeonCard(
                        glowColor: statusColor.withValues(alpha: 0.4),
                        child: ListTile(
                          leading: FaIcon(
                            _getIconForType(doc.fileType),
                            color: Colors.white,
                          ),
                          title: Text(
                            doc.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            _getStatusText(doc.status),
                            style: TextStyle(color: statusColor, fontSize: 12),
                          ),
                          onTap: () => _handleDocumentTap(doc),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // --- BOTÓN FLOTANTE VISIBLE PARA TODOS (UNIVERSAL) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadDocument,
        backgroundColor: AppColors.accentMagenta,
        icon: const Icon(Icons.cloud_upload, color: Colors.white),
        label: const Text(
          'Subir Archivo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
