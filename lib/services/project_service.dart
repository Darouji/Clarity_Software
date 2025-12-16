// lib/services/project_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/project.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream de proyectos (filtrado por rol)
  Stream<List<Project>> getProjectsStream(String userId, String role) {
    Query query = _db.collection('projects');

    if (role == 'client') {
      // Si es cliente, solo ve sus propios proyectos
      query = query.where('clientId', isEqualTo: userId);
    }
    // Si es admin (u otro rol), ve todo (o filtramos según lógica futura)
    // Actualmente el AdminProjectListScreen ya filtra por clientId al llamar a este stream.

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Project.fromJson(data);
      }).toList();
    });
  }

  Stream<Project> getProjectStream(String projectId) {
    return _db.collection('projects').doc(projectId).snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Project.fromJson(data);
    });
  }

  Future<void> createProject(Project project) async {
    // Si el ID viene vacío, Firestore genera uno
    final docRef = _db.collection('projects').doc();
    final projectData = project.toJson();
    projectData['id'] = docRef.id; // Asignamos el ID generado

    await docRef.set(projectData);
  }

  Future<void> updateProject(Project project) async {
    await _db.collection('projects').doc(project.id).update(project.toJson());
  }

  Future<void> deleteProject(String projectId) async {
    await _db.collection('projects').doc(projectId).delete();
  }

  Future<void> saveProject(Project newProject) async {}
}
