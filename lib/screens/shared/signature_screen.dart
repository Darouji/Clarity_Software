// lib/screens/shared/signature_screen.dart
import 'dart:ui' as ui;
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});
  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final List<Offset?> _points = [];
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _saveSignature() async {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor firma primero.'),
          backgroundColor: AppColors.accentRed));
      return;
    }
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      // Aquí iría el código para subir 'image' a Firebase Storage
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Firma guardada exitosamente'),
            backgroundColor: AppColors.accentGreen));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al guardar'),
          backgroundColor: AppColors.accentRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
          title: const Text('Firma Digital',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.appBarBackground,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            TextButton(
                onPressed: () => setState(() => _points.clear()),
                child: const Text('Limpiar',
                    style: TextStyle(color: AppColors.accentRed)))
          ]),
      body: Column(children: [
        const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Firma en el recuadro.',
                style: TextStyle(color: Colors.white70))),
        Expanded(
            child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyberBlue, width: 2)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RepaintBoundary(
                        key: _globalKey,
                        child: GestureDetector(
                            onPanUpdate: (d) =>
                                setState(() => _points.add(d.localPosition)),
                            onPanEnd: (d) => _points.add(null),
                            child: CustomPaint(
                                painter: _SignaturePainter(_points),
                                size: Size.infinite)))))),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
                onPressed: _saveSignature,
                icon: const Icon(Icons.check, color: Colors.black),
                label: const Text('GUARDAR',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))))),
      ]),
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
      if (points[i] != null && points[i + 1] != null)
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
