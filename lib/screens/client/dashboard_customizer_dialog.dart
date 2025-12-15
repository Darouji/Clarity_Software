// lib/screens/client/dashboard_customizer_dialog.dart
import 'package:clarity_software/models/dashboard_config.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardCustomizerDialog extends StatefulWidget {
  final DashboardConfig initialConfig;

  const DashboardCustomizerDialog({super.key, required this.initialConfig});

  @override
  State<DashboardCustomizerDialog> createState() =>
      _DashboardCustomizerDialogState();
}

class _DashboardCustomizerDialogState extends State<DashboardCustomizerDialog> {
  late bool _showCharts;
  late bool _showStats;
  late bool _showProjects;
  // --- NUEVO: Estado para el calendario ---
  late bool _showCalendar;

  @override
  void initState() {
    super.initState();
    _showCharts = widget.initialConfig.showCharts;
    _showStats = widget.initialConfig.showStats;
    _showProjects = widget.initialConfig.showProjects;
    // --- NUEVO ---
    _showCalendar = widget.initialConfig.showCalendar;
  }

  void _save() {
    final newConfig = widget.initialConfig.copyWith(
      showCharts: _showCharts,
      showStats: _showStats,
      showProjects: _showProjects,
      // --- NUEVO ---
      showCalendar: _showCalendar,
    );
    Navigator.pop(context, newConfig);
  }

  Widget _buildSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppColors.cyberBlue),
      activeColor: AppColors.cyberBlue,
      tileColor: AppColors.cardBackground.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: const Text(
        'Personalizar Dashboard',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Activa o desactiva los módulos que deseas ver en tu pantalla de inicio.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildSwitch(
              'Gráficos de Progreso',
              'Visualización circular y de barras',
              _showCharts,
              (v) => setState(() => _showCharts = v),
              Icons.pie_chart_outline,
            ),
            const SizedBox(height: 10),
            _buildSwitch(
              'Estadísticas Rápidas',
              'Estado, Presupuesto, Equipo',
              _showStats,
              (v) => setState(() => _showStats = v),
              Icons.bar_chart,
            ),
            const SizedBox(height: 10),
            _buildSwitch(
              'Lista de Proyectos',
              'Tarjetas detalladas de tus proyectos',
              _showProjects,
              (v) => setState(() => _showProjects = v),
              Icons.folder_open,
            ),
            // --- NUEVO SWITCH DE CALENDARIO ---
            const SizedBox(height: 10),
            _buildSwitch(
              'Agenda y Calendario',
              'Próximos hitos y enlace a Google Calendar',
              _showCalendar,
              (v) => setState(() => _showCalendar = v),
              Icons.calendar_month,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentMagenta,
            foregroundColor: Colors.white,
          ),
          child: const Text('Guardar Cambios'),
        ),
      ],
    );
  }
}
