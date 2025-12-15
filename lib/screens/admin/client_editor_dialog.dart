// lib/screens/admin/client_editor_dialog.dart
import 'package:flutter/material.dart';
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/theme/app_colors.dart';

class ClientEditorDialog extends StatefulWidget {
  final ClientUser? client;

  const ClientEditorDialog({super.key, this.client});

  @override
  State<ClientEditorDialog> createState() => _ClientEditorDialogState();
}

class _ClientEditorDialogState extends State<ClientEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _role = 'client';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    if (widget.client != null) {
      _role = widget.client!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newClient = ClientUser(
        id: widget.client?.id ?? '',
        name: _nameController.text,
        email: _emailController.text,
        role: _role,
        photoUrl: widget.client?.photoUrl ?? '',
      );

      Navigator.pop(context, newClient);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.client != null;

    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
        style: const TextStyle(color: AppColors.primaryText),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: const InputDecoration(labelText: 'Email (Google)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              // NOTA: Ignora la advertencia de 'value deprecated' si aparece,
              // DropdownButtonFormField requiere 'value' para controlar el estado actual.
              DropdownButtonFormField<String>(
                initialValue: _role,
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'client', child: Text('Cliente')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _role = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentMagenta,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
