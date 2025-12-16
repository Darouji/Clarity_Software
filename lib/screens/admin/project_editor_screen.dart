// lib/screens/admin/project_editor_screen.dart
import 'dart:ui';

import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/admin/milestone_editor_dialog.dart';
import 'package:clarity_software/services/project_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/neon_card.dart';
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
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late TextEditingController _teamController;
  late TextEditingController _techController;

  // Lista local de hitos para editar antes de guardar
  late List<Milestone> _milestones;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
    _budgetController = TextEditingController(
      text: widget.project?.budget ?? '',
    );
    _teamController = TextEditingController(
      text: widget.project?.team.join(', ') ?? '',
    );
    _techController = TextEditingController(
      text: widget.project?.technologies.join(', ') ?? '',
    );

    // Inicializamos los hitos con una copia de los existentes o vacía
    _milestones = List.from(widget.project?.milestones ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _teamController.dispose();
    _techController.dispose();
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
        // Ordenamos por fecha límite
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

  Color _getMilestoneStatusColor(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return AppColors.accentGreen;
      case MilestoneStatus.inProgress:
        return AppColors.cyberBlue;
      default:
        return AppColors.grey;
    }
  }

  // --- GUARDADO ---

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final List<String> teamList = _teamController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final List<String> techList = _techController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newProject = Project(
        clientId: widget.clientId,
        id: widget.project?.id ?? '', // Si es '', el servicio crea ID nuevo
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        budget: _budgetController.text.trim(),
        team: teamList,
        technologies: techList,
        milestones: _milestones, // Usamos la lista actualizada
        lastUpdate: DateTime.now(),
      );

      if (widget.project == null) {
        await _projectService.createProject(newProject);
      } else {
        await _projectService.updateProject(newProject);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proyecto guardado correctamente'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    String? helperText,
    TextStyle? helperStyle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: AppColors.cyberBlue),
      helperText: helperText,
      helperStyle: helperStyle,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.cyberBlue),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.project != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor: AppColors.appBarBackground.withValues(
                alpha: 0.8,
              ),
              elevation: 0,
              leading: const BackButton(color: Colors.white),
              title: Text(
                isEditing ? 'Editar Proyecto' : 'Nuevo Proyecto',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: const [GlobalAppBarMenu(currentScreen: AppScreen.admin)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeonCard(
                glowColor: AppColors.cyberBlue.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        'Nombre del Proyecto',
                        Icons.folder,
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: _buildInputDecoration(
                        'Descripción',
                        Icons.description,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(
                        'Presupuesto',
                        Icons.attach_money,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              NeonCard(
                glowColor: AppColors.accentMagenta.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles Técnicos',
                      style: TextStyle(
                        color: AppColors.accentMagenta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _teamController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        'Equipo (separado por comas)',
                        Icons.group,
                        helperText: 'Ej: Juan, Maria, Carlos',
                        helperStyle: const TextStyle(color: Colors.white30),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _techController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        'Tecnologías (separadas por comas)',
                        Icons.code,
                        helperText: 'Ej: Flutter, Firebase, Node.js',
                        helperStyle: const TextStyle(color: Colors.white30),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- SECCIÓN DE HITOS (Milestones) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Línea de Tiempo (Hitos)',
                    style: TextStyle(
                      color: AppColors.accentMagenta,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.accentMagenta,
                      size: 28,
                    ),
                    onPressed: _addMilestone,
                    tooltip: 'Agregar Hito',
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 20),

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
                    final color = _getMilestoneStatusColor(milestone.status);

                    return Card(
                      color: AppColors.cardBackground,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: color.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.2),
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
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white30,
                            size: 20,
                          ),
                          onPressed: () => _removeMilestone(index),
                        ),
                        onTap: () => _editMilestone(index),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProject,
                  icon: const Icon(Icons.save, color: Colors.black),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          isEditing ? 'ACTUALIZAR PROYECTO' : 'CREAR PROYECTO',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyberBlue,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
