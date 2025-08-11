import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette de couleurs pour le mode clair
  static final _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.blue[700]!,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF70F7F7),
    onPrimaryContainer: Color(0xFF002020),
    secondary: Colors.blue[700]!,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCCE8E7),
    onSecondaryContainer: Color(0xFF051F1F),
    tertiary: Colors.blue[700]!,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD2E4FF),
    onTertiaryContainer: Color(0xFF041C35),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    background: Color(0xFFF4FAFA),
    onBackground: Color(0xFF161D1D),
    surface: Color(0xFFF4FAFA),
    onSurface: Color(0xFF161D1D),
    surfaceVariant: Color(0xFFDAE5E4),
    onSurfaceVariant: Color(0xFF3F4948),
    outline: Color(0xFF6F7979),
    inverseSurface: Color(0xFF2B3232),
    onInverseSurface: Color(0xFFEBF2F1),
    inversePrimary: Color(0xFF4CDADA),
    shadow: Color(0xFF000000),
  );

  // Palette de couleurs pour le mode sombre
  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4CDADA),
    onPrimary: Color(0xFF003737),
    primaryContainer: Color(0xFF005050),
    onPrimaryContainer: Color(0xFF70F7F7),
    secondary: Color(0xFFB1CCCB),
    onSecondary: Color(0xFF1B3535),
    secondaryContainer: Color(0xFF324B4B),
    onSecondaryContainer: Color(0xFFCCE8E7),
    tertiary: Color(0xFFB2C8E8),
    onTertiary: Color(0xFF1A314B),
    tertiaryContainer: Color(0xFF324863),
    onTertiaryContainer: Color(0xFFD2E4FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    background: Color(0xFF0F1414),
    onBackground: Color(0xFFDEE4E3),
    surface: Color(0xFF0F1414),
    onSurface: Color(0xFFDEE4E3),
    surfaceVariant: Color(0xFF3F4948),
    onSurfaceVariant: Color(0xFFBEC9C8),
    outline: Color(0xFF899392),
    inverseSurface: Color(0xFFDEE4E3),
    onInverseSurface: Color(0xFF161D1D),
    inversePrimary: Color(0xFF006A6A),
    shadow: Color(0xFF000000),
  );

  static ThemeData getTheme(bool isDarkMode) {
    final colorScheme = isDarkMode ? _darkColorScheme : _lightColorScheme;
    final textTheme = GoogleFonts.poppinsTextTheme(
      isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).copyWith(
      headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.poppins(),
      bodyMedium: GoogleFonts.poppins(),
    );

    return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: textTheme.titleLarge?.copyWith(color:Colors.blue[700],),
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
            textStyle: textTheme.titleMedium,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.tertiary,
          foregroundColor: colorScheme.onTertiary,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: colorScheme.inverseSurface,
          contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        )
    );
  }
}
