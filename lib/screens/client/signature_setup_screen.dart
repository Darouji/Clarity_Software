// lib/screens/client/signature_setup_screen.dart
import 'dart:io';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class SignatureSetupScreen extends StatefulWidget {
  const SignatureSetupScreen({super.key});

  @override
  State<SignatureSetupScreen> createState() => _SignatureSetupScreenState();
}

class _SignatureSetupScreenState extends State<SignatureSetupScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.isEmpty != _isEmpty) {
        setState(() {
          _isEmpty = _controller.isEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _clearSignature() async {
    _controller.clear();
  }

  Future<void> _saveSignature() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor firma antes de guardar.')),
      );
      return;
    }

    final signatureImage = await _controller.toPngBytes();

    if (signatureImage != null) {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/signature.png').create();
      await file.writeAsBytes(signatureImage);

      if (mounted) {
        Navigator.pop(context, file.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Configurar Firma',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _clearSignature,
            child: const Text('Limpiar',
                style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Firma dentro del recuadro blanco.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cyberBlue),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isEmpty ? null : _saveSignature,
                icon: const Icon(Icons.check, color: Colors.black),
                label: const Text(
                  'GUARDAR FIRMA',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
