import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

ThemeData mainTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: posBg,
  colorScheme: ColorScheme.dark(
    surface: posSurface,
    surfaceContainerHighest: posSurfaceLight,
    primary: posPrimary,
    onPrimary: Colors.white,
    secondary: posAccent,
    onSecondary: posTextMain,
    onSurface: Colors.white,
    onSurfaceVariant: posTextMuted,
    outline: Colors.white.withValues(alpha: 0.08),
    outlineVariant: Colors.white.withValues(alpha: 0.05),
  ),
  cardColor: posSurface,
  cardTheme: CardThemeData(
    color: posSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.white.withValues(alpha: 0.05),
    thickness: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: posPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 0,
      textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: posAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: posTextMuted),
  ),
  textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
    bodySmall: GoogleFonts.outfit(color: posTextMuted, fontSize: 12),
    bodyMedium: GoogleFonts.outfit(
      color: Colors.white.withValues(alpha: 0.85),
      fontSize: 14,
    ),
    bodyLarge: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.w800,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.black.withValues(alpha: 0.3),
    hintStyle: GoogleFonts.outfit(
      color: posTextMuted.withValues(alpha: 0.5),
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: posPrimary, width: 1.5),
    ),
    prefixIconColor: posTextMuted,
    suffixIconColor: posTextMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: posSurface,
    foregroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: posTextMuted,
    indicator: BoxDecoration(
      color: posSurfaceLight,
      borderRadius: BorderRadius.circular(12),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: Colors.transparent,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: posSurfaceLight,
    selectedColor: posPrimary,
    labelStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: posSurfaceLight,
    contentTextStyle: GoogleFonts.outfit(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: posSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
    elevation: 0,
    titleTextStyle: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: GoogleFonts.outfit(color: posTextMuted, fontSize: 14),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: posSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
    elevation: 8,
    textStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
  ),
);
