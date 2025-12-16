// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart'; // Importamos nuestra paleta de colores

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // --- CAMBIO AQUÍ ---
    // Has pedido usar el negro cyberpunk como fondo principal.
    scaffoldBackgroundColor:
        AppColors.primaryBackground, // Usamos el negro puro
    // --- FIN DEL CAMBIO ---
    primaryColor: AppColors.accentMagenta,
    cardColor: AppColors.cardBlack,
    appBarTheme: AppBarTheme(
      // CORRECCIÓN: Usamos withAlpha en lugar de withOpacity
      backgroundColor: AppColors.primaryBackground.withAlpha(
        153,
      ), // ~60% opacity
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: 'Roboto',
        color: AppColors.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryText),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBlack,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: AppColors.primaryText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.secondaryText, fontSize: 14),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.accentMagenta,
    cardColor: AppColors.lightSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightAppBarBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        color: AppColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.darkText),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.darkText,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: AppColors.darkText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.darkSecondaryText, fontSize: 14),
    ),
  );
}
