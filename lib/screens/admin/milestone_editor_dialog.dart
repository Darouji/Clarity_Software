// lib/screens/admin/milestone_editor_dialog.dart
import 'package:clarity_software/models/milestone.dart';
import 'package:flutter/material.dart';

class MilestoneEditorDialog extends StatefulWidget {
  final Milestone? milestone;
  final List<String> teamMembers;

  const MilestoneEditorDialog({
    super.key,
    this.milestone,
    this.teamMembers = const [],
  });

  @override
  State<MilestoneEditorDialog> createState() => _MilestoneEditorDialogState();
}

class _MilestoneEditorDialogState extends State<MilestoneEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _textResponsibleController;
  late String _responsibleDropdownValue;
  late bool _useDropdown;
  late double _progress;
  late DateTime _startDate;
  late DateTime _deadline;
  late MilestoneFase _fase;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.milestone?.title ?? '',
    );
    _progress = widget.milestone?.progress ?? 0.0;
    _startDate = widget.milestone?.startDate ?? DateTime.now();
    _deadline =
        widget.milestone?.deadline ??
        DateTime.now().add(const Duration(days: 7));
    _fase = widget.milestone?.fase ?? MilestoneFase.planificacion;

    _useDropdown = widget.teamMembers.isNotEmpty;

    if (_useDropdown) {
      String initialResponsible = widget.milestone?.responsible ?? '';
      if (widget.teamMembers.contains(initialResponsible)) {
        _responsibleDropdownValue = initialResponsible;
      } else {
        _responsibleDropdownValue = widget.teamMembers.first;
      }
      _textResponsibleController = TextEditingController();
    } else {
      _textResponsibleController = TextEditingController(
        text: widget.milestone?.responsible ?? '',
      );
      _responsibleDropdownValue = '';
    }
  }

  Future<void> _pickDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
        } else {
          _deadline = date;
        }
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final MilestoneStatus newStatus;
      if (_progress == 0.0) {
        newStatus = MilestoneStatus.pending;
      } else if (_progress == 1.0) {
        newStatus = MilestoneStatus.completed;
      } else {
        newStatus = MilestoneStatus.inProgress;
      }

      final String finalResponsible = _useDropdown
          ? _responsibleDropdownValue
          : _textResponsibleController.text;

      final newMilestone = Milestone(
        title: _titleController.text,
        responsible: finalResponsible,
        status: newStatus,
        progress: _progress,
        startDate: _startDate,
        deadline: _deadline,
        fase: _fase,
      );
      Navigator.of(context).pop(newMilestone);
    }
  }

  Widget _buildResponsibleField() {
    if (_useDropdown) {
      return DropdownButtonFormField<String>(
        initialValue: _responsibleDropdownValue,
        decoration: const InputDecoration(labelText: 'Responsable'),
        items: widget.teamMembers
            .map((name) => DropdownMenuItem(value: name, child: Text(name)))
            .toList(),
        onChanged: (value) =>
            setState(() => _responsibleDropdownValue = value!),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Campo requerido' : null,
      );
    } else {
      return TextFormField(
        controller: _textResponsibleController,
        decoration: const InputDecoration(labelText: 'Responsable'),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Campo requerido' : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.milestone == null ? 'Nuevo Hito' : 'Editar Hito'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título del Hito'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              _buildResponsibleField(),
              DropdownButtonFormField<MilestoneFase>(
                // --- INICIO DE CORRECCIÓN LINT ---
                initialValue:
                    _fase, // Usamos 'value' en lugar de 'initialValue'
                // --- FIN DE CORRECCIÓN LINT ---
                decoration: const InputDecoration(labelText: 'Fase'),
                items: MilestoneFase.values
                    .map(
                      (fase) => DropdownMenuItem(
                        value: fase,
                        child: Text(getFaseName(fase)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _fase = value!),
              ),
              const SizedBox(height: 16),
              Text('Progreso: ${(_progress * 100).toStringAsFixed(0)}%'),
              Slider(
                value: _progress,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                label: '${(_progress * 100).toStringAsFixed(0)}%',
                onChanged: (value) => setState(() => _progress = value),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inicio: ${_startDate.toLocal().toString().split(' ')[0]}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(true),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vence: ${_deadline.toLocal().toString().split(' ')[0]}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
