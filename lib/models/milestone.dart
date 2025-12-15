// lib/models/milestone.dart

// --- NUEVO: Definición de las 3 Fases del proyecto ---
enum MilestoneFase { planificacion, desarrollo, revision }

// Función simple para obtener un nombre legible
String getFaseName(MilestoneFase fase) {
  switch (fase) {
    case MilestoneFase.planificacion:
      return 'Planificación';
    case MilestoneFase.desarrollo:
      return 'Desarrollo';
    case MilestoneFase.revision:
      return 'Revisión'; // <-- CAMBIO DE NOMBRE
  }
}
// --- FIN DE LO NUEVO ---

// Define el estado de un hito. 'enum' es una forma de crear un tipo
// que solo puede tener uno de los valores predefinidos.
enum MilestoneStatus { completed, inProgress, pending }

// Modelo para cada Hito Clave de un proyecto.
class Milestone {
  final String title;
  final double progress; // De 0.0 a 1.0
  final MilestoneStatus status;
  final String responsible;
  final DateTime startDate;
  final DateTime deadline;
  final MilestoneFase fase; // <-- NUEVA PROPIEDAD

  Milestone({
    required this.title,
    required this.progress,
    required this.status,
    required this.responsible,
    required this.startDate,
    required this.deadline,
    required this.fase, // <-- NUEVA PROPIEDAD
  });

  // --- Métodos para guardar/cargar en JSON ---
  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      title: json['title'],
      progress: json['progress'],
      // Convertir el String guardado de nuevo a un enum
      status: MilestoneStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MilestoneStatus.pending,
      ),
      responsible: json['responsible'],
      // Convertir el String ISO de nuevo a DateTime
      startDate: DateTime.parse(json['startDate']),
      deadline: DateTime.parse(json['deadline']),
      // --- NUEVO: Cargar la fase ---
      fase: MilestoneFase.values.firstWhere(
        (e) => e.toString() == json['fase'],
        orElse: () => MilestoneFase.planificacion, // Valor por defecto
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'progress': progress,
      'status': status.toString(), // Guardar el enum como String
      'responsible': responsible,
      'startDate': startDate.toIso8601String(), // Guardar fechas como String
      'deadline': deadline.toIso8601String(),
      'fase': fase.toString(), // <-- NUEVA PROPIEDAD
    };
  }

  // --- FIN DE LO NUEVO ---
}
