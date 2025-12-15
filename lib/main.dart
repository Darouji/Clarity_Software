// lib/main.dart

import 'package:flutter/material.dart';
// --- NUEVO: Importamos el núcleo de Firebase ---
import 'package:firebase_core/firebase_core.dart';
import 'package:clarity_software/theme/app_theme.dart';
import 'package:clarity_software/screens/login_screen.dart';
import 'package:clarity_software/services/mock_api_service.dart';
import 'package:clarity_software/services/feedback_notification_service.dart';

Future<void> main() async {
  // Aseguramos que el motor gráfico de Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // --- CORRECCIÓN CRÍTICA ---
  // Inicializamos Firebase antes de cualquier otra cosa.
  // Esto lee el archivo google-services.json que colocaste y conecta la app.
  await Firebase.initializeApp();
  // -------------------------

  // Inicializamos el servicio de API (Mock)
  // Nota: Pronto quitaremos esto cuando migremos todo a ProjectService
  await MockApiService().init();

  // Inicializamos el servicio de Feedback
  await FeedbackNotificationService().init();

  // Ahora sí corremos la app
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
      home: const LoginScreen(),
    );
  }
}
