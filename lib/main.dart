import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarity_software/theme/app_theme.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/screens/login_screen.dart';
import 'package:clarity_software/screens/client/overview_screen.dart';
import 'package:clarity_software/screens/admin/admin_dashboard_screen.dart';
import 'package:clarity_software/services/feedback_notification_service.dart';
import 'package:clarity_software/services/user_service.dart';
import 'package:clarity_software/models/client_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FeedbackNotificationService().init();
  runApp(const ClaritySoftware());
}

class ClaritySoftware extends StatelessWidget {
  const ClaritySoftware({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarity Software',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Usamos el Wrapper como home para decidir qué mostrar
      home: const AuthWrapper(),
    );
  }
}

/// Widget encargado de gestionar el estado de la sesión en tiempo real
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Debug para ver en consola qué está pasando
        if (snapshot.connectionState == ConnectionState.active) {
          print("AUTH WRAPPER: Detectó cambio. Usuario: ${snapshot.data?.uid}");
        }

        // 1. Si hay error en la conexión con Firebase
        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: AppColors.primaryBackground,
            body: Center(
              child: Text(
                "Error de conexión con Authentication",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        // 2. Si está cargando el estado inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.primaryBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.cyberBlue),
            ),
          );
        }

        // 3. Si NO hay usuario, mostramos Login
        if (!snapshot.hasData || snapshot.data == null) {
          print("AUTH WRAPPER: No hay usuario, mostrando LoginScreen.");
          return const LoginScreen();
        }

        // 4. Si HAY usuario autenticado, verificamos su rol en Firestore
        final User firebaseUser = snapshot.data!;

        return FutureBuilder<ClientUser?>(
          future: UserService().getUserById(firebaseUser.uid),
          builder: (context, userSnapshot) {
            // Mientras esperamos los datos del perfil (rol)
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.primaryBackground,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.cyberBlue),
                ),
              );
            }

            final user = userSnapshot.data;

            // Decisión basada en el rol
            if (user != null && user.isAdmin) {
              print(
                  "AUTH WRAPPER: Usuario es Admin. Redirigiendo a Dashboard.");
              return const AdminDashboardScreen();
            } else {
              print(
                  "AUTH WRAPPER: Usuario es Cliente (o default). Redirigiendo a Overview.");
              return const OverviewScreen();
            }
          },
        );
      },
    );
  }
}
