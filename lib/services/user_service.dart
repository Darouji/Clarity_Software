// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/client_user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // --- OBTENER TODOS LOS USUARIOS (STREAM) ---
  Stream<List<ClientUser>> getClientsStream() {
    return _db
        .collection(_collection)
        .where('role', isEqualTo: 'client')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClientUser.fromJson(doc.data());
      }).toList();
    });
  }

  // --- OBTENER UN USUARIO POR ID (ROBUSTO) ---
  Future<ClientUser?> getUserById(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return ClientUser.fromJson(doc.data()!);
      }
    } catch (e) {
      print("Error obteniendo usuario: $e");
      // Si falla, retornamos null para que el AuthWrapper al menos cargue la vista de Cliente por defecto
    }
    return null;
  }

  // --- STREAM DE UN SOLO USUARIO ---
  Stream<ClientUser?> getUserStream(String userId) {
    return _db.collection(_collection).doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ClientUser.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // --- GUARDAR O ACTUALIZAR USUARIO COMPLETO ---
  Future<void> saveUser(ClientUser user) async {
    String userId = user.id;
    if (userId.isEmpty) {
      userId = _db.collection(_collection).doc().id;
    }

    final userToSave = ClientUser(
      id: userId,
      name: user.name,
      email: user.email,
      role: user.role,
      photoUrl: user.photoUrl,
      signatureUrl: user.signatureUrl,
      hasSignatureConfigured: user.hasSignatureConfigured,
    );

    await _db.collection(_collection).doc(userId).set(userToSave.toJson());
  }

  // --- ACTUALIZAR SOLO LA FIRMA ---
  Future<void> updateUserSignature(String userId, String signatureUrl) async {
    await _db.collection(_collection).doc(userId).update({
      'signatureUrl': signatureUrl,
      'hasSignatureConfigured': true,
    });
  }

  // --- ACTUALIZAR NOMBRE ---
  Future<void> updateUserName(String userId, String newName) async {
    await _db.collection(_collection).doc(userId).update({'name': newName});
  }
}
