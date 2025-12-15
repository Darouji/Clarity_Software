// lib/services/project_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/project.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'projects';

  // --- OBTENER PROYECTOS (STREAM) ---
  // Usamos Streams para que la UI se actualice sola si algo cambia en la nube
  Stream<List<Project>> getProjectsStream(String userId, String role) {
    Query query = _db.collection(_collection);

    // Si NO es admin, solo ve sus propios proyectos
    if (role != 'admin') {
      query = query.where('clientId', isEqualTo: userId);
    }

    // Ordenar por última actualización (requiere crear un índice en Firebase después)
    // query = query.orderBy('lastUpdate', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Añadimos el ID del documento al objeto por seguridad
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Aseguramos que el ID del modelo coincida con el ID del documento
        data['id'] = doc.id;
        return Project.fromJson(data);
      }).toList();
    });
  }

  // --- NUEVO: ESCUCHAR UN SOLO PROYECTO (Para ProjectDetailsScreen) ---
  Stream<Project> getProjectStream(String projectId) {
    return _db.collection(_collection).doc(projectId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Project.fromJson(data);
      } else {
        throw Exception("Proyecto no encontrado");
      }
    });
  }

  // --- GUARDAR O ACTUALIZAR PROYECTO ---
  Future<void> saveProject(Project project) async {
    final docRef = _db
        .collection(_collection)
        .doc(project.id.isNotEmpty ? project.id : null);

    // Al guardar, actualizamos la fecha automáticamente
    final projectToSave = Project(
      clientId: project.clientId,
      id: docRef.id, // Usamos el ID generado o existente
      name: project.name,
      description: project.description,
      budget: project.budget,
      team: project.team,
      technologies: project.technologies,
      milestones: project.milestones,
      lastUpdate: DateTime.now(), // <-- Actualizamos fecha
    );

    await docRef.set(projectToSave.toJson());
  }

  // --- ELIMINAR PROYECTO ---
  Future<void> deleteProject(String projectId) async {
    await _db.collection(_collection).doc(projectId).delete();
  }

  // --- INICIALIZACIÓN DE DATOS DEMO (Solo usar una vez) ---
  // Llama a esto si quieres subir tus proyectos mock a la base de datos real
  Future<void> uploadMockData(List<Project> mockProjects) async {
    for (var p in mockProjects) {
      await saveProject(p);
    }
  }
}
