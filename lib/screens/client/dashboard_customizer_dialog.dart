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
  // Estado local para los switches
  late Map<String, bool> _visibility;
  // Estado local para el orden
  late List<String> _orderedIds;

  final Map<String, String> _labels = {
    'shortcuts': 'Accesos Rápidos (Citas)',
    'charts': 'Gráficos de Progreso',
    'stats': 'Estadísticas Globales',
    'calendar': 'Agenda y Calendario',
    'projects': 'Lista de Proyectos',
  };

  // ignore: unused_field
  final Map<String, IconData> _icons = {
    'shortcuts': Icons.bolt,
    'charts': Icons.pie_chart,
    'stats': Icons.bar_chart,
    'calendar': Icons.calendar_today,
    'projects': Icons.folder_open,
  };

  @override
  void initState() {
    super.initState();
    _visibility = {
      'shortcuts': widget.initialConfig.showShortcuts,
      'charts': widget.initialConfig.showCharts,
      'stats': widget.initialConfig.showStats,
      'calendar': widget.initialConfig.showCalendar,
      'projects': widget.initialConfig.showProjects,
    };
    _orderedIds = List.from(widget.initialConfig.layout);
  }

  void _save() {
    final newConfig = widget.initialConfig.copyWith(
      showShortcuts: _visibility['shortcuts'],
      showCharts: _visibility['charts'],
      showStats: _visibility['stats'],
      showCalendar: _visibility['calendar'],
      showProjects: _visibility['projects'],
      layout: _orderedIds,
    );
    Navigator.pop(context, newConfig);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: const Text(
        'Organizar Dashboard',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // Altura fija para permitir scroll interno
        child: Column(
          children: [
            const Text(
              'Arrastra los bloques para reordenarlos y usa el switch para ocultarlos.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final String item = _orderedIds.removeAt(oldIndex);
                    _orderedIds.insert(newIndex, item);
                  });
                },
                children: [
                  for (final id in _orderedIds)
                    ListTile(
                      key: ValueKey(id),
                      leading: Icon(Icons.drag_handle, color: Colors.white30),
                      title: Text(
                        _labels[id]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Switch(
                        value: _visibility[id]!,
                        activeThumbColor: AppColors.accentMagenta,
                        onChanged: (val) {
                          setState(() {
                            _visibility[id] = val;
                          });
                        },
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
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
            backgroundColor: AppColors.cyberBlue,
            foregroundColor: Colors.black,
          ),
          child: const Text('Guardar Orden'),
        ),
      ],
    );
  }
}
