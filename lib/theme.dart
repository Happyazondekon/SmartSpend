import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getAppTheme(bool isDarkMode) {
  return ThemeData(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue[50],
    appBarTheme: AppBarTheme(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blue,
    ),
    cardTheme: CardTheme(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    ),
  );
}