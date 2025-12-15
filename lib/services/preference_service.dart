// lib/services/preference_service.dart

import 'dart:async';
import 'package:flutter/material.dart'; // <-- CORRECCIÓN: Import faltante

// Define las vistas que el usuario puede elegir
enum ProjectViewPreference { overview, list }

// Un servicio Singleton para gestionar las preferencias del usuario.
// En una app real, esto usaría SharedPreferences o una base de datos.
// Por ahora, solo lo mantendrá en memoria durante la sesión.
class PreferenceService {
  // --- Singleton Setup ---
  static final PreferenceService _instance = PreferenceService._internal();
  factory PreferenceService() => _instance;
  PreferenceService._internal();

  // --- Preferencia de Vista ---
  ProjectViewPreference _currentViewPreference =
      ProjectViewPreference.overview; // Valor por defecto

  // Stream para notificar a los widgets (como la pantalla de login) si la preferencia cambia
  final StreamController<ProjectViewPreference> _preferenceController =
      StreamController<ProjectViewPreference>.broadcast();

  // Obtener la preferencia actual
  ProjectViewPreference get currentPreference => _currentViewPreference;

  // Obtener el stream para escuchar cambios
  Stream<ProjectViewPreference> get preferenceStream =>
      _preferenceController.stream;

  // Guardar la preferencia y notificar a los oyentes
  void saveViewPreference(ProjectViewPreference preference) {
    _currentViewPreference = preference;
    _preferenceController.add(preference);
    debugPrint(
      "Preferencia guardada: $preference",
    ); // <-- CORRECCIÓN: 'P' minúscula
  }
}
