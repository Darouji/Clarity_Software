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

  // --- OBTENER UN USUARIO POR ID ---
  Future<ClientUser?> getUserById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      return ClientUser.fromJson(doc.data()!);
    }
    return null;
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

  // --- NUEVO: ACTUALIZAR SOLO LA FIRMA ---
  Future<void> updateUserSignature(String userId, String signatureUrl) async {
    await _db.collection(_collection).doc(userId).update({
      'signatureUrl': signatureUrl,
      'hasSignatureConfigured': true,
    });
  }
}
