// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Colores de Fondo ---
  static const Color primaryBackground = Color(0xFF000000); // Negro Puro
  static const Color cyberpunkBlack = Color(0xFF0D1117);
  static const Color cardBackground = Color(0xFF161B22);
  static const Color cardBlack = Color(0xFF161B22);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;

  // --- Colores de Acento y Neón (Paleta Principal) ---
  static const Color accentMagenta = Color(0xFFF50087);
  static const Color accentYellow = Color(0xFFF3EA5F);
  static const Color accentGreen = Color(0xFF00FF7F);
  static const Color accentBlue = Colors.blueAccent;
  static const Color cyberBlue = Color(0xFF00F6FF);
  static const Color smoothBlue = Color(0xFF4A6A8A);
  static const Color accentPurple = Color(0xFF6A4C9C);
  static const Color softLilac = Color(0xFF9B88ED);
  static const Color accentOrange = Colors.orange;
  static const Color tonalBlue = Color(0xFF4A6A8A);

  // --- Colores para bordes/iconos de InfoBlock ---
  static const Color neonYellow = Color(0xFFF3EA5F);
  static const Color neonMoneyGreen = Color(0xFF4DFA7B);
  static const Color neonPink = Color(0xFFF50087);

  // --- Colores de Texto y Neutros ---
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.white70;
  static const Color darkText = Colors.black87;
  static const Color darkSecondaryText = Colors.black54;
  static const Color grey = Colors.grey;
  static const Color black = Colors.black;

  // --- Colores de Estado de Proyecto ---
  static const Color statusOff = Color(0xFF2D333B);
  static const Color statusFinishedText = Color(0xFF4DFA7B);

  // --- Colores Varios ---
  static const Color accentRed = Colors.redAccent;
  // CORRECCIÓN: Se agrega appBarBackground para solucionar el error en ChatScreen
  static const Color appBarBackground = Color(0xFF161B22);
  static const Color lightAppBarBackground = Color(0x99FFFFFF);
  static const Color statusInitial = Color(0x809E9E9E);
}
