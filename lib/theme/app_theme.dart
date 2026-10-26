import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Background and text colors for the Luppy themes.
class AppColors {
  AppColors._();

  static const background = Color(0xFF0B0B0D);
  static const surface = Color(0xFF14151A);

  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFB4B4BC);
  static const textMuted = Color(0xFF7C7C86);

  static const lightBackground = Color(0xFFF8F8FA);
  static const lightSurface = Colors.white;

  static const lightTextPrimary = Color(0xFF16161A);
  static const lightTextSecondary = Color(0xFF5F5F68);
  static const lightTextMuted = Color(0xFF8C8C96);
}

class AppTheme {
  AppTheme._();

  static final TextTheme _textTheme = GoogleFonts.interTextTheme(
    const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textMuted),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
  );

  static final TextTheme _lightTextTheme = GoogleFonts.interTextTheme(
    const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 14,  fontWeight: FontWeight.w300, color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
      bodySmall: TextStyle(
        fontSize: 12,
       
        color: AppColors.lightTextMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: _textTheme.titleMedium,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    canvasColor: AppColors.lightBackground,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: _lightTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: _lightTextTheme.titleMedium,
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
    ),
  );
}
