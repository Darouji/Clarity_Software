// lib/widgets/info_block.dart
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class InfoBlock extends StatelessWidget {
  const InfoBlock({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.glowColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.primaryText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        // --- INICIO DE CORRECCIÓN LINT ---
        color: AppColors.primaryText.withAlpha(
          (255 * 0.1).round(),
        ), // withAlpha
        // --- FIN DE CORRECCIÓN LINT ---
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Lo centramos verticalmente
        children: [
          Icon(icon, size: 22, color: glowColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    // --- INICIO DE CORRECCIÓN LINT ---
                    color: textColor.withAlpha(
                      (255 * 0.7).round(),
                    ), // withAlpha
                    // --- FIN DE CORRECCIÓN LINT ---
                    height: 1.0,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
