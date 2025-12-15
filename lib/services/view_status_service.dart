// lib/services/view_status_service.dart

// Este es un servicio simulado para llevar un registro de los proyectos que
// el cliente ha visto durante la sesión actual de la app.
// En una aplicación real, esto se manejaría con una base de datos.
class ViewStatusService {
  // Singleton para asegurarnos de que solo haya una instancia de este servicio.
  static final ViewStatusService _instance = ViewStatusService._internal();
  factory ViewStatusService() => _instance;
  ViewStatusService._internal();

  // Un conjunto (Set) para almacenar los IDs de los proyectos vistos.
  // Usamos un Set porque es más eficiente para verificar si un elemento existe.
  final Set<String> _viewedProjectIds = {};

  // Método para marcar un proyecto como visto.
  void markAsViewed(String projectId) {
    _viewedProjectIds.add(projectId);
  }

  // Método para verificar si un proyecto ha sido visto.
  bool hasBeenViewed(String projectId) {
    return _viewedProjectIds.contains(projectId);
  }
}
