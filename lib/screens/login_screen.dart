import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clarity_software/main.dart'; // Importante para poder navegar a ClaritySoftware
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/models/client_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Intentamos Loguear
      final ClientUser? user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. LOGICA DE NAVEGACIÓN FORZADA
      if (user != null && mounted) {
        print("LOGIN SCREEN: Login exitoso. Forzando navegación a Home.");

        // Esto elimina el historial de navegación y reinicia la app en ClaritySoftware
        // lo que disparará el AuthWrapper de main.dart con el usuario ya cargado.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ClaritySoftware()),
          (route) => false,
        );
      } else if (mounted) {
        _showErrorSnackBar('Credenciales inválidas o error de conexión.');
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceAll('Exception: ', '');
        _showErrorSnackBar(msg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        print("LOGIN SCREEN: Google Login exitoso. Forzando navegación.");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ClaritySoftware()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error de conexión con Google.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Recuperar Cuenta',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: resetEmailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(color: AppColors.cyberBlue),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.cyberBlue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resetEmailController.text.isNotEmpty) {
                final email = resetEmailController.text.trim();
                try {
                  Navigator.pop(dialogContext); // Cerramos diálogo primero
                  await _authService.sendPasswordResetEmail(email);
                  if (mounted) {
                    _showSuccessSnackBar(
                        'Correo de recuperación enviado a $email.');
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorSnackBar(
                        'No se pudo enviar el correo. Verifica que exista.');
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyberBlue,
            ),
            child: const Text('Enviar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.accentMagenta,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.secondaryText),
      prefixIcon: Icon(icon, color: AppColors.cyberBlue, size: 20),
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.cardBackground),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cyberBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 180,
                    maxHeight: 180,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyberBlue.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logos/logo_clarity.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    'Correo electrónico',
                    Icons.email_outlined,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa tu correo' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration('Contraseña', Icons.lock_outline)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa tu contraseña' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: AppColors.cyberBlue.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator(color: AppColors.cyberBlue)
                else
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleEmailSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyberBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.cyberBlue.withValues(alpha: 0.4),
                      ),
                      child: const Text(
                        'INGRESAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'O continúa con',
                        style: TextStyle(
                          color: AppColors.secondaryText.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Iniciar sesión con Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
