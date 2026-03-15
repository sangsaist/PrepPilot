import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF5C6BC0);
  static const Color scaffoldBackgroundColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFF8F9FA);
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  static const Color darkPrimaryColor = Color(0xFF7986CB);
  static const Color darkScaffoldBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkPrimaryText = Color(0xFFEEEEEE);
  static const Color darkSecondaryText = Color(0xFF9E9E9E);
  static const Color darkBorderColor = Color(0xFF2C2C2C);
  static const Color darkAppBarColor = Color(0xFF1A1A1A);

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
          side: const BorderSide(color: borderColor, width: 1),
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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkScaffoldBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        primary: darkPrimaryColor,
        brightness: Brightness.dark,
        background: darkScaffoldBackgroundColor,
        surface: darkScaffoldBackgroundColor,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkPrimaryText),
        bodyMedium: TextStyle(color: darkPrimaryText),
        bodySmall: TextStyle(color: darkSecondaryText),
        titleLarge: TextStyle(color: darkPrimaryText, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: darkPrimaryText, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: darkPrimaryText, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkAppBarColor,
        foregroundColor: darkPrimaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: darkPrimaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorderColor, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkAppBarColor,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: darkSecondaryText,
        elevation: 0,
      ),
    );
  }
}
