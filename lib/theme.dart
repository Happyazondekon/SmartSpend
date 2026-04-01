import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette de couleurs pour le mode clair - Design moderne
  static final _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0284C7),         // Bleu professionnel
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0F2FE),
    onPrimaryContainer: Color(0xFF0C4A6E),
    secondary: Color(0xFF0369A1),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFBAE6FD),
    onSecondaryContainer: Color(0xFF0C4A6E),
    tertiary: Color(0xFF0EA5E9),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE0F2FE),
    onTertiaryContainer: Color(0xFF0C4A6E),
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    background: Color(0xFFF8FAFC),       // Fond blanc cassé
    onBackground: Color(0xFF0F172A),
    surface: Color(0xFFFFFFFF),          // Cards blanches
    onSurface: Color(0xFF0F172A),
    surfaceVariant: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFFCBD5E1),
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF1F5F9),
    inversePrimary: Color(0xFF38BDF8),
    shadow: Color(0xFF000000),
  );

  // Palette de couleurs pour le mode sombre - Design moderne
  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF0EA5E9),          // Bleu cyan clair
    onPrimary: Color(0xFF0C4A6E),
    primaryContainer: Color(0xFF0369A1),
    onPrimaryContainer: Color(0xFFE0F2FE),
    secondary: Color(0xFF38BDF8),
    onSecondary: Color(0xFF0C4A6E),
    secondaryContainer: Color(0xFF0284C7),
    onSecondaryContainer: Color(0xFFE0F2FE),
    tertiary: Color(0xFF7DD3FC),
    onTertiary: Color(0xFF0C4A6E),
    tertiaryContainer: Color(0xFF0369A1),
    onTertiaryContainer: Color(0xFFE0F2FE),
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    errorContainer: Color(0xFF991B1B),
    onErrorContainer: Color(0xFFFECACA),
    background: Color(0xFF0A0F14),       // Fond sombre profond
    onBackground: Color(0xFFF1F5F9),
    surface: Color(0xFF111827),          // Cards sombres
    onSurface: Color(0xFFF1F5F9),
    surfaceVariant: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF334155),
    inverseSurface: Color(0xFFF1F5F9),
    onInverseSurface: Color(0xFF0F172A),
    inversePrimary: Color(0xFF0284C7),
    shadow: Color(0xFF000000),
  );

  static ThemeData getTheme(bool isDarkMode) {
    final colorScheme = isDarkMode ? _darkColorScheme : _lightColorScheme;

    // CORRECTION: Définir explicitement les couleurs de base pour le textTheme
    final baseTextTheme = isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    final textTheme = GoogleFonts.poppinsTextTheme(baseTextTheme).copyWith(
      // Définir explicitement les couleurs pour chaque style de texte
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: colorScheme.onBackground, // AJOUT: couleur explicite
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface, // AJOUT: couleur explicite
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface, // AJOUT: couleur explicite
      ),
      bodyLarge: GoogleFonts.poppins(
        color: colorScheme.onBackground, // AJOUT: couleur explicite
      ),
      bodyMedium: GoogleFonts.poppins(
        color: colorScheme.onSurface, // AJOUT: couleur explicite
      ),
      bodySmall: GoogleFonts.poppins(
        color: colorScheme.onSurfaceVariant, // AJOUT: couleur explicite
      ),
      // AJOUT: Autres styles de texte
      displayLarge: GoogleFonts.poppins(color: colorScheme.onBackground),
      displayMedium: GoogleFonts.poppins(color: colorScheme.onBackground),
      displaySmall: GoogleFonts.poppins(color: colorScheme.onBackground),
      headlineLarge: GoogleFonts.poppins(color: colorScheme.onBackground),
      headlineMedium: GoogleFonts.poppins(color: colorScheme.onBackground),
      labelLarge: GoogleFonts.poppins(color: colorScheme.onSurface),
      labelMedium: GoogleFonts.poppins(color: colorScheme.onSurface),
      labelSmall: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDarkMode ? colorScheme.primary : Colors.blue[700], // CORRECTION: adaptation mode sombre
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface), // AJOUT: couleur des icônes
      ),
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.primary, width: 3),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.background,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onBackground), // AJOUT
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface), // AJOUT
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
      // AJOUT: Autres thèmes pour assurer la cohérence
      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium,
        leadingAndTrailingTextStyle: textTheme.bodyMedium,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        textStyle: textTheme.bodyMedium,
      ),
    );
  }
}