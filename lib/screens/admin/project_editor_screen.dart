// lib/screens/admin/project_editor_screen.dart
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/admin/milestone_editor_dialog.dart';
import 'package:clarity_software/services/project_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectEditorScreen extends StatefulWidget {
  final Project? project;
  final String clientId;

  const ProjectEditorScreen({super.key, this.project, required this.clientId});

  @override
  State<ProjectEditorScreen> createState() => _ProjectEditorScreenState();
}

class _ProjectEditorScreenState extends State<ProjectEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProjectService _projectService = ProjectService();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _budgetController;

  // Lista local de hitos para editar antes de guardar
  late List<Milestone> _milestones;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descController = TextEditingController(
      text: widget.project?.description ?? '',
    );
    _budgetController = TextEditingController(
      text: widget.project?.budget ?? '',
    );
    // Creamos una copia modificable de la lista de hitos
    _milestones = List.from(widget.project?.milestones ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  // --- GESTIÓN DE HITOS ---

  Future<void> _addMilestone() async {
    final newMilestone = await showDialog<Milestone>(
      context: context,
      builder: (context) => const MilestoneEditorDialog(),
    );

    if (newMilestone != null) {
      setState(() {
        _milestones.add(newMilestone);
        // Ordenamos por fecha para mantener coherencia
        _milestones.sort((a, b) => a.deadline.compareTo(b.deadline));
      });
    }
  }

  Future<void> _editMilestone(int index) async {
    final editedMilestone = await showDialog<Milestone>(
      context: context,
      builder: (context) =>
          MilestoneEditorDialog(milestone: _milestones[index]),
    );

    if (editedMilestone != null) {
      setState(() {
        _milestones[index] = editedMilestone;
        _milestones.sort((a, b) => a.deadline.compareTo(b.deadline));
      });
    }
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestones.removeAt(index);
    });
  }

  // --- GUARDADO ---

  void _save() async {
    if (_formKey.currentState!.validate()) {
      // Creamos el objeto proyecto completo con los nuevos hitos
      final newProject = Project(
        clientId: widget.clientId,
        // Si ya existe ID lo usamos, si no, lo dejamos vacío
        id: widget.project?.id ?? '',
        name: _nameController.text,
        description: _descController.text,
        budget: _budgetController.text,
        team:
            widget.project?.team ?? [], // Mantenemos equipo existente por ahora
        technologies: widget.project?.technologies ?? [],
        milestones: _milestones, // <--- LISTA DE HITOS ACTUALIZADA
        lastUpdate: DateTime.now(),
      );

      await _projectService.saveProject(newProject);

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  // --- UI HELPERS ---

  Color _getStatusColor(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return AppColors.accentGreen;
      case MilestoneStatus.inProgress:
        return AppColors.cyberBlue;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project == null ? 'Nuevo Proyecto' : 'Editar Proyecto',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.accentGreen),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- DATOS GENERALES ---
              const Text(
                'Información General',
                style: TextStyle(
                  color: AppColors.cyberBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Proyecto',
                  prefixIcon: Icon(
                    Icons.folder_outlined,
                    color: Colors.white54,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(
                    Icons.description_outlined,
                    color: Colors.white54,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Presupuesto',
                  prefixIcon: Icon(Icons.attach_money, color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 30),

              // --- SECCIÓN DE HITOS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Línea de Tiempo (Hitos)',
                    style: TextStyle(
                      color: AppColors.accentMagenta,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.accentMagenta,
                    ),
                    onPressed: _addMilestone,
                    tooltip: 'Agregar Hito',
                  ),
                ],
              ),
              const Divider(color: Colors.white24),

              if (_milestones.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No hay hitos definidos.\nAgrega uno para comenzar el cronograma.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = _milestones[index];
                    final color = _getStatusColor(milestone.status);

                    return Card(
                      color: AppColors.cardBackground,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: color.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Icon(Icons.flag, color: color, size: 20),
                        ),
                        title: Text(
                          milestone.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat('dd/MM').format(milestone.deadline)} • ${milestone.responsible}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(milestone.progress * 100).toInt()}%',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.white30,
                                size: 20,
                              ),
                              onPressed: () => _removeMilestone(index),
                            ),
                          ],
                        ),
                        onTap: () => _editMilestone(index),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 40),

              // Botón Guardar Principal
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'GUARDAR PROYECTO',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
