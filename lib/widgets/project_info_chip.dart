// lib/widgets/project_info_chip.dart
import 'package:flutter/material.dart';

class ProjectInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProjectInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    // El color del texto se adaptará automáticamente al tema (blanco en oscuro, negro en claro)
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Row(
      mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
      children: [
        Icon(icon, size: 16, color: textColor?.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          '$label:',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: textColor)),
      ],
    );
  }
}
