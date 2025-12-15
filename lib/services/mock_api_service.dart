// lib/services/mock_api_service.dart
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/models/client_user.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // --- CLIENTES ---
  final List<ClientUser> _clients = [
    ClientUser(
      id: '1',
      name: 'Empresa Demo S.A.',
      email: 'contacto@demo.com',
      role: 'client',
    ),
    ClientUser(
      id: '2',
      name: 'StartUp Innovadora',
      email: 'ceo@startup.com',
      role: 'client',
    ),
    ClientUser(
      id: 'admin_1',
      name: 'Administrador Clarity',
      email: 'admin@clarity.com',
      role: 'admin',
    ),
  ];

  List<ClientUser> getClients() {
    return _clients;
  }

  Future<void> saveClient(ClientUser client) async {
    final index = _clients.indexWhere((c) => c.id == client.id);
    if (index >= 0) {
      _clients[index] = client;
    } else {
      final newClient = ClientUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: client.name,
        email: client.email,
        role: client.role,
        photoUrl: client.photoUrl,
      );
      _clients.add(newClient);
    }
  }

  // --- PROYECTOS ---
  final List<Project> _projects = [
    Project(
      clientId: '1',
      id: 'p1',
      name: 'Campaña SEO 2024',
      description: 'Optimización completa de motores de búsqueda.',
      budget: '1500',
      team: ['Ana', 'Carlos'],
      technologies: ['SEO', 'Analytics'],
      lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
      milestones: [
        Milestone(
          title: 'Auditoría Inicial',
          progress: 1.0,
          status: MilestoneStatus.completed,
          responsible: 'Ana',
          startDate: DateTime(2024, 1, 10),
          deadline: DateTime(2024, 1, 15),
          fase: MilestoneFase.planificacion,
        ),
      ],
    ),
  ];

  List<Project> getProjectsForClient(String clientId) {
    return _projects.where((p) => p.clientId == clientId).toList();
  }

  // --- NUEVOS MÉTODOS PARA CORREGIR ERRORES ---

  Future<void> saveProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
    } else {
      _projects.add(project);
    }
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
