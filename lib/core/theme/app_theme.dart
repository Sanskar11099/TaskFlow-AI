import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: _buildTextTheme(AppColors.onSurface),
        inputDecorationTheme: _inputDecorationTheme(dark: true),
        elevatedButtonTheme: _elevatedButtonTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.inversePrimary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryContainer,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightOnSurface,
          surfaceContainer: AppColors.lightSurfaceContainer,
          outline: AppColors.outline,
          outlineVariant: Color(0xFFD0CDE8),
          error: Color(0xFFB3261E),
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        textTheme: _buildTextTheme(AppColors.lightOnSurface),
        inputDecorationTheme: _inputDecorationTheme(dark: false),
        elevatedButtonTheme: _elevatedButtonTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightOnSurface,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFD0CDE8), width: 1),
          ),
        ),
      );

  static TextTheme _buildTextTheme(Color color) => TextTheme(
        displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, color: color),
        displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, color: color),
        headlineLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3, color: color),
        headlineMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3, color: color),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, height: 1.4, color: color),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4, color: color),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: color),
        bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.6, color: color),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6, color: color),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4, color: color.withValues(alpha: 0.7)),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: color),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: color.withValues(alpha: 0.6)),
      );

  static InputDecorationTheme _inputDecorationTheme({required bool dark}) => InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceContainer,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dark ? AppColors.outlineVariant : const Color(0xFFD0CDE8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );
}
