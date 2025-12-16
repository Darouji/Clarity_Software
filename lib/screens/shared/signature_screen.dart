// lib/screens/shared/signature_screen.dart
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  // CORRECCIÓN: 'final' porque la referencia a la lista no cambia (solo su contenido)
  final List<Offset?> _points = [];

  void _clearSignature() {
    setState(() {
      _points.clear();
    });
  }

  void _saveSignature() {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, realiza tu firma antes de guardar.'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Firma Digital',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _clearSignature,
            child: const Text(
              'Limpiar',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Firma en el recuadro blanco usando tu dedo.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cyberBlue, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _points.add(details.localPosition);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _points.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    _points.add(null);
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(_points),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _saveSignature,
              icon: const Icon(Icons.check, color: Colors.black),
              label: const Text(
                'CONFIRMAR FIRMA',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
