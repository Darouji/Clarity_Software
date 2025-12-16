// lib/services/auth_service.dart
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  ClientUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return ClientUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'Usuario',
      role: 'client',
      photoUrl: user.photoURL ?? '',
    );
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<ClientUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      User? firebaseUser = _auth.currentUser;

      // Si no hay usuario o es diferente al que intenta entrar, hacemos login
      if (firebaseUser == null || firebaseUser.email != email) {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        firebaseUser = result.user;
      }

      if (firebaseUser != null) {
        try {
          final dbUser = await _userService.getUserById(firebaseUser.uid);
          if (dbUser != null) {
            return dbUser;
          }
        } catch (e) {
          print("Error obteniendo usuario de DB: $e");
        }

        return ClientUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Usuario',
          role: 'client',
          photoUrl: firebaseUser.photoURL ?? '',
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No existe usuario con este correo.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta.');
      } else if (e.code == 'invalid-email') {
        throw Exception('El formato del correo no es válido.');
      } else {
        throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ... (Resto de métodos igual) ...

  Future<ClientUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        ClientUser? existingUser = await _userService.getUserById(user.uid);

        if (existingUser == null) {
          final newUser = ClientUser(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'Nuevo Usuario',
            role: 'client',
            photoUrl: user.photoURL ?? '',
          );
          try {
            await _userService.saveUser(newUser);
          } catch (_) {}
          return newUser;
        }
        return existingUser;
      }
      return null;
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
