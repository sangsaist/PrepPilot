import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF5C6BC0);
  static const Color scaffoldBackgroundColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFF8F9FA);
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        background: scaffoldBackgroundColor,
        surface: scaffoldBackgroundColor,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: primaryText),
        bodyMedium: TextStyle(color: primaryText),
        bodySmall: TextStyle(color: secondaryText),
        titleLarge: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: scaffoldBackgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryText,
        elevation: 0,
      ),
    );
  }
}
