import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Landmark's visual identity: a deep navy/teal paired with a warm gold
/// accent (the kind of palette the original splash logo used), set on
/// Plus Jakarta Sans for a cleaner, more deliberate look than bare Material
/// defaults. Centralized here so every screen inherits it rather than
/// hand-rolling colors/shapes per widget.
class LandmarkColors {
  static const navy = Color(0xFF0E2A47);
  static const navyDeep = Color(0xFF0A1F35);
  static const teal = Color(0xFF0E4C6B);
  static const gold = Color(0xFFC9972F);
  static const goldLight = Color(0xFFE4B65A);
  static const background = Color(0xFFF6F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1C2630);
  static const inkMuted = Color(0xFF6B7684);
  static const success = Color(0xFF2E9B5F);
  static const danger = Color(0xFFD0483E);
}

ThemeData buildLandmarkTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: LandmarkColors.navy,
    brightness: Brightness.light,
    primary: LandmarkColors.navy,
    secondary: LandmarkColors.gold,
    surface: LandmarkColors.surface,
  );

  final textTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
    displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 30, fontWeight: FontWeight.w700, color: LandmarkColors.ink, letterSpacing: -0.5),
    headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w700, color: LandmarkColors.ink),
    titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w700, color: LandmarkColors.ink),
    titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15.5, fontWeight: FontWeight.w600, color: LandmarkColors.ink),
    bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 15, color: LandmarkColors.ink, height: 1.4),
    bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: LandmarkColors.inkMuted, height: 1.4),
    labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: base,
    scaffoldBackgroundColor: LandmarkColors.background,
    textTheme: textTheme,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

    appBarTheme: AppBarTheme(
      backgroundColor: LandmarkColors.background,
      foregroundColor: LandmarkColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w700, color: LandmarkColors.ink),
      iconTheme: const IconThemeData(color: LandmarkColors.ink),
    ),

    cardTheme: CardThemeData(
      color: LandmarkColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: LandmarkColors.navy.withOpacity(0.05),
      selectedColor: LandmarkColors.navy,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: LandmarkColors.ink, fontWeight: FontWeight.w500),
      secondaryLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: LandmarkColors.navy.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: LandmarkColors.navy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LandmarkColors.navy,
        side: BorderSide(color: LandmarkColors.navy.withOpacity(0.35)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: LandmarkColors.navy,
        textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LandmarkColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LandmarkColors.navy.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LandmarkColors.navy.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LandmarkColors.navy, width: 1.4),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(color: LandmarkColors.inkMuted, fontSize: 14),
      hintStyle: GoogleFonts.plusJakartaSans(color: LandmarkColors.inkMuted, fontSize: 14),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: LandmarkColors.surface,
      selectedItemColor: LandmarkColors.navy,
      unselectedItemColor: LandmarkColors.inkMuted,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11.5),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    dividerTheme: DividerThemeData(color: LandmarkColors.navy.withOpacity(0.08), thickness: 1),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: LandmarkColors.gold,
      foregroundColor: LandmarkColors.navyDeep,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? LandmarkColors.navy : null),
      trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? LandmarkColors.navy.withOpacity(0.4) : null),
    ),
  );
}
