import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme {
  static const Color brandSeed = Color(0xFF00C805); // Fintech Emerald
  static const Color profitGreen = Color(0xFF00C805);
  static const Color lossRed = Color(0xFFFF3B30);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: brandSeed,
    scaffoldBackgroundColor: const Color(0xFF0C1017),
    cardTheme: CardThemeData(
      color: const Color(0xFF121820),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E2633), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0C1017),
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      headlineMedium: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      titleLarge: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      titleMedium: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      bodyLarge: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      bodyMedium: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      labelLarge: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: brandSeed,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FA),
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      headlineMedium: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      titleLarge: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      titleMedium: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      bodyLarge: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      bodyMedium: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      labelLarge: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
    ),
  );
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark; // Dark mode default as specified in Gate 4

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
