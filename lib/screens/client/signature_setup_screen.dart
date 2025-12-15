// lib/screens/client/signature_setup_screen.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/services/storage_service.dart';
import 'package:clarity_software/services/user_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';

class SignatureSetupScreen extends StatefulWidget {
  const SignatureSetupScreen({super.key});

  @override
  State<SignatureSetupScreen> createState() => _SignatureSetupScreenState();
}

class _SignatureSetupScreenState extends State<SignatureSetupScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  bool _isSaving = false;
  final StorageService _storageService = StorageService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _clearPad() async {
    _controller.clear();
  }

  Future<void> _saveSignature() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, dibuja tu firma primero.'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Exportar firma a bytes (PNG)
      final Uint8List? data = await _controller.toPngBytes();
      if (data == null) return;

      // 2. Crear archivo temporal
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/signature.png').create();
      await file.writeAsBytes(data);

      // 3. Subir a Firebase Storage
      final user = _authService.currentUser;
      if (user == null) return;

      final String downloadUrl = await _storageService.uploadFile(
        file,
        'signatures/${user.id}',
      );

      // 4. Actualizar perfil de usuario en Firestore
      await _userService.updateUserSignature(user.id, downloadUrl);

      // 5. Feedback y Salir
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firma configurada correctamente.'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.pop(context, true); // Retornamos true para indicar éxito
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Firma Digital'),
        actions: const [
          GlobalAppBarMenu(currentScreen: AppScreen.notifications),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Dibuja tu firma a continuación.\nEsta será utilizada para aprobar documentos legales.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 20),
            // Área de Firma
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cyberBlue, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botones de Acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _clearPad,
                    icon: const Icon(Icons.clear, color: AppColors.accentRed),
                    label: const Text(
                      'Borrar',
                      style: TextStyle(color: AppColors.accentRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveSignature,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.check, color: Colors.black),
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Guardar Firma',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyberBlue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
