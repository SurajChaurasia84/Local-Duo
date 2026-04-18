import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6A11CB);
  static const Color secondaryColor = Color(0xFF2575FC);
  
  // Solid Dark Palette
  static const Color darkBackgroundColor = Colors.black;
  static const Color darkCardColor = Color(0xFF121212);
  
  // Solid Light Palette
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightCardColor = Color(0xFFF5F5F7);

  static ThemeData light = _createTheme(Brightness.light);
  static ThemeData dark = _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    bool isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: isDark ? darkBackgroundColor : lightBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        secondary: secondaryColor,
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTint: Colors.transparent,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
        bodyLarge: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black87),
      ),
      cardTheme: CardThemeData(
        color: isDark ? darkCardColor : lightCardColor,
        elevation: isDark ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkBackgroundColor : lightBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20, 
          fontWeight: FontWeight.bold, 
          color: isDark ? Colors.white : Colors.black,
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }
}
