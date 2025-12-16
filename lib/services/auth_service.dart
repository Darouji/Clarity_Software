// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clarity_software/models/client_user.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ClientUser? _currentUser;
  ClientUser? get currentUser => _currentUser;

  Stream<ClientUser?> get authStateChanges async* {
    yield* _auth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        return null;
      }
      _currentUser = await _fetchOrCreateUserFromFirestore(firebaseUser);
      return _currentUser;
    });
  }

  Future<ClientUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user != null) {
        _currentUser = await _fetchOrCreateUserFromFirestore(user);
        return _currentUser;
      }
    } catch (e) {
      debugPrint("Error en Email Sign-In: $e");
      rethrow;
    }
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<ClientUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        _currentUser = await _fetchOrCreateUserFromFirestore(user);
        return _currentUser;
      }
    } catch (e) {
      debugPrint("Error en Google Sign-In: $e");
      return null;
    }
    return null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
  }

  Future<ClientUser> _fetchOrCreateUserFromFirestore(User firebaseUser) async {
    final userRef = _db.collection('users').doc(firebaseUser.uid);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      return ClientUser.fromJson(snapshot.data()!);
    } else {
      final newUser = ClientUser(
        id: firebaseUser.uid,
        name:
            firebaseUser.displayName ??
            firebaseUser.email?.split('@')[0] ??
            'Usuario',
        email: firebaseUser.email ?? '',
        role: 'client',
        photoUrl: firebaseUser.photoURL ?? '',
      );
      await userRef.set(newUser.toJson());
      return newUser;
    }
  }
}
