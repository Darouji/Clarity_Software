// lib/widgets/neon_card.dart
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap; // Agregado para soportar clics

  const NeonCard({
    super.key,
    required this.child,
    required this.glowColor,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor = AppColors.cardBlack.withAlpha(240);

    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: glowColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:
                glowColor.withValues(alpha: 0.15), // Ajuste seguro de opacidad
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.0),
          child: Padding(
            padding: padding!,
            child: child,
          ),
        ),
      ),
    );
  }
}
