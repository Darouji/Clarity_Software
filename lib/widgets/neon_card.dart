// lib/widgets/neon_card.dart
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsetsGeometry? padding;

  const NeonCard({
    super.key,
    required this.child,
    required this.glowColor,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor = AppColors.cardBlack.withAlpha(240);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        // 1. Borde con el color del proyecto
        border: Border.all(color: glowColor, width: 1.5),
        // 2. Brillo (BoxShadow) con el alfa en 40
        boxShadow: [
          BoxShadow(
            // --- CAMBIO AQUÍ ---
            // Aplicamos el alfa de 40 que definiste.
            color: glowColor.withAlpha(40),
            // --- FIN DEL CAMBIO ---
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0), // Sombra centrada
          ),
        ],
      ),
      child: child,
    );
  }
}
