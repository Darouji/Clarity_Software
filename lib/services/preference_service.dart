// lib/services/preference_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/dashboard_config.dart';
import 'package:clarity_software/services/auth_service.dart';

class PreferenceService {
  static final PreferenceService _instance = PreferenceService._internal();
  factory PreferenceService() => _instance;
  PreferenceService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Referencia al documento de configuración del usuario actual
  DocumentReference get _configRef {
    final user = _authService.currentUser;
    if (user == null) throw Exception('No user logged in');
    return _db
        .collection('users')
        .doc(user.id)
        .collection('settings')
        .doc('dashboard_config');
  }

  // --- STREAM: Escuchar cambios en tiempo real ---
  Stream<DashboardConfig> getDashboardConfigStream() {
    try {
      final user = _authService.currentUser;
      if (user == null) return Stream.value(DashboardConfig());

      return _db
          .collection('users')
          .doc(user.id)
          .collection('settings')
          .doc('dashboard_config')
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              return DashboardConfig.fromJson(
                snapshot.data() as Map<String, dynamic>,
              );
            }
            return DashboardConfig(); // Configuración por defecto
          });
    } catch (e) {
      print('Error en PreferenceService stream: $e');
      return Stream.value(DashboardConfig());
    }
  }

  // --- GUARDAR CONFIGURACIÓN ---
  Future<void> saveDashboardConfig(DashboardConfig config) async {
    try {
      await _configRef.set(config.toJson());
    } catch (e) {
      print('Error guardando preferencias: $e');
      rethrow;
    }
  }
}
