import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);
  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xffb69aff),
          brightness: brightness,
        ).copyWith(
          primary: Color(dark ? 0xffb69aff : 0xff5b36b4),
          onPrimary: Color(dark ? 0xff181122 : 0xffffffff),
          surface: Color(dark ? 0xff1c1a23 : 0xffffffff),
          onSurface: Color(dark ? 0xfff8f7fc : 0xff1b1823),
          onSurfaceVariant: Color(dark ? 0xffb8b2c5 : 0xff5f596b),
          error: Color(dark ? 0xffffb4ab : 0xff9f1f2d),
        );
    return ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.iOS,
      colorScheme: scheme,
      scaffoldBackgroundColor: Color(dark ? 0xff111015 : 0xfff8f7fc),
      fontFamily: const CupertinoThemeData().textTheme.textStyle.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(dark ? 0xff111015 : 0xfff8f7fc),
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      textTheme: TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          height: 40 / 34,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 34 / 28,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 26 / 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 20 / 14,
          color: scheme.onSurfaceVariant,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
