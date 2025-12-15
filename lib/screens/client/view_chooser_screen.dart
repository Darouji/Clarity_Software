// lib/screens/client/view_chooser_screen.dart
import 'package:clarity_software/screens/client/global_timeline_screen.dart';
import 'package:clarity_software/screens/client/overview_screen.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class ViewChooserScreen extends StatelessWidget {
  const ViewChooserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Función para crear las tarjetas de selección
    Widget buildChoiceCard({
      required BuildContext context,
      required String title,
      required String description,
      required IconData icon,
      required Color color,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: NeonCard(
          glowColor: color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(description, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige tu Experiencia'),
        automaticallyImplyLeading: false, // Oculta el botón de "atrás"
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Cómo prefieres ver tus proyectos?',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            buildChoiceCard(
              context: context,
              title: 'Dashboard',
              description:
                  'Vista de "portafolio". Un resumen gerencial de tus proyectos, progreso y presupuesto.',
              icon: Icons.dashboard_outlined,
              color: AppColors.cyberBlue,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OverviewScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            buildChoiceCard(
              context: context,
              title: 'Timeline',
              description:
                  'Vista de "actividad". Un feed cronológico de los próximos hitos y entregas.',
              icon: Icons.timeline_outlined,
              color: AppColors.accentMagenta,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GlobalTimelineScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
