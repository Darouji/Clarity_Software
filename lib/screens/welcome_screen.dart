// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  final Widget destination;
  final String userName; // Mantenemos el parámetro por si se usa en el futuro

  const WelcomeScreen({
    super.key,
    required this.destination,
    required this.userName,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showWelcomeText = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    // Pequeña espera para que la transición de pantalla se complete
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _showWelcomeText = true;
      });
    }

    // Espera 2 segundos y luego navega al destino
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.destination),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _showWelcomeText ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          // --- CAMBIOS AQUÍ ---
          // 1. Reemplazamos el Text por un Column
          child: Column(
            mainAxisSize: MainAxisSize.min, // Para mantener centrado vertical
            children: [
              // 2. Añadimos el logo de Clarity
              Image.asset(
                'assets/logos/logo_clarity.png',
                height: 180, // Misma altura que en la pantalla de login
              ),
              const SizedBox(height: 20), // Un espacio entre el logo y el texto
              // 3. Cambiamos el texto para quitar el nombre de usuario
              Text(
                '¡Bienvenido!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // --- FIN DE LOS CAMBIOS ---
        ),
      ),
    );
  }
}
