// lib/services/preference_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/dashboard_config.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint

class PreferenceService {
  static final PreferenceService _instance = PreferenceService._internal();
  factory PreferenceService() => _instance;
  PreferenceService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  DocumentReference get _configRef {
    final user = _authService.currentUser;
    if (user == null) throw Exception('No user logged in');
    return _db
        .collection('users')
        .doc(user.id)
        .collection('settings')
        .doc('dashboard_config');
  }

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
            return DashboardConfig();
          });
    } catch (e) {
      debugPrint('Error en PreferenceService stream: $e'); // CORRECCIÓN
      return Stream.value(DashboardConfig());
    }
  }

  Future<void> saveDashboardConfig(DashboardConfig config) async {
    try {
      await _configRef.set(config.toJson());
    } catch (e) {
      debugPrint('Error guardando preferencias: $e'); // CORRECCIÓN
      rethrow;
    }
  }
}
