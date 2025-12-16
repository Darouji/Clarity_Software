// lib/widgets/dashboard_tile.dart
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badgeText;

  // Control de Edición
  final bool isEditMode;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;

  const DashboardTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeText,
    this.isEditMode = false,
    this.isVisible = true,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible && !isEditMode) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: (isEditMode && !isVisible) ? 0.4 : 1.0,
          child: GestureDetector(
            onTap: isEditMode ? null : onTap,
            child: NeonCard(
              glowColor: color.withValues(alpha: 0.3),
              padding: EdgeInsets
                  .zero, // Quitamos padding interno para control total
              child: SizedBox(
                height: double.infinity, // Forzar altura completa en grilla
                width: double.infinity, // Forzar ancho completo
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Círculo de fondo para el icono
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 32, color: color),
                        ),
                        if (badgeText != null)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.accentRed,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                badgeText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2, // Permitir 2 líneas si es largo
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w600, // Semi-bold para mejor lectura
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Botón de Edición (Círculo)
        if (isEditMode)
          Positioned(
            top: -6,
            left: -6,
            child: GestureDetector(
              onTap: onToggleVisibility,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isVisible
                      ? AppColors.accentRed
                      : AppColors.accentGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isVisible ? Icons.remove : Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
