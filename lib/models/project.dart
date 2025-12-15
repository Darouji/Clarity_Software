// lib/models/project.dart
import 'package:clarity_software/models/milestone.dart';

class Project {
  // --- INICIO DE CAMBIO ---
  final String clientId; // ID del ClientUser al que pertenece
  // --- FIN DE CAMBIO ---
  final String id;
  final String name;
  final String description;
  final String budget;
  final List<String> team;
  final List<String> technologies;
  final List<Milestone> milestones;
  final DateTime
  lastUpdate; // Propiedad necesaria para la pantalla de Visión General

  const Project({
    required this.clientId, // <-- Añadido al constructor
    required this.id,
    required this.name,
    required this.description,
    required this.budget, // Vuelve a ser String como en el original
    required this.team,
    required this.technologies,
    required this.milestones,
    required this.lastUpdate, // Añadido al constructor
  });

  // El getter de progreso se mantiene como en la versión original
  double get overallProgress {
    if (milestones.isEmpty) {
      return 0.0;
    }
    final double totalProgress = milestones.fold(
      0.0,
      (sum, item) => sum + item.progress,
    );
    return totalProgress / milestones.length;
  }

  // El getter de estado se mantiene como en la versión original
  String get status {
    final progress = overallProgress;
    if (progress == 1.0) {
      return 'Finalizado';
    } else if (progress >= 0.7) {
      return 'Avanzado';
    } else if (progress > 0.0) {
      return 'En Proceso';
    } else {
      return 'Inicial';
    }
  }

  // --- Métodos para guardar/cargar en JSON (ACTUALIZADOS) ---
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      clientId: json['clientId'] ?? 'default_client', // <-- Añadido
      id: json['id'],
      name: json['name'],
      description: json['description'],
      budget: json['budget'],
      team: List<String>.from(json['team']),
      technologies: List<String>.from(json['technologies']),
      milestones: (json['milestones'] as List)
          .map((i) => Milestone.fromJson(i))
          .toList(),
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId, // <-- Añadido
      'id': id,
      'name': name,
      'description': description,
      'budget': budget,
      'team': team,
      'technologies': technologies,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}
