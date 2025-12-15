// lib/screens/admin/project_editor_screen.dart
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/services/mock_api_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProjectEditorScreen extends StatefulWidget {
  final Project? project;
  final String clientId;

  const ProjectEditorScreen({super.key, this.project, required this.clientId});

  @override
  State<ProjectEditorScreen> createState() => _ProjectEditorScreenState();
}

class _ProjectEditorScreenState extends State<ProjectEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final MockApiService _apiService = MockApiService();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _budgetController;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final newProject = Project(
        clientId: widget.clientId,
        id:
            widget.project?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descController.text,
        budget: _budgetController.text,
        team: widget.project?.team ?? [],
        technologies: widget.project?.technologies ?? [],
        milestones: widget.project?.milestones ?? [],
        lastUpdate: DateTime.now(),
      );

      // --- AQUÍ ESTABA EL ERROR: Ahora saveProject sí existe ---
      await _apiService.saveProject(newProject);

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project == null ? 'Nuevo Proyecto' : 'Editar Proyecto',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Proyecto',
                ),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Presupuesto'),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text('Guardar Proyecto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
