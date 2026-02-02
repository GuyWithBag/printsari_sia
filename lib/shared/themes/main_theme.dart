import 'package:flutter/material.dart';

const textColor = Colors.black;

ThemeData mainTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey[200],
  // Define the primary swatch
  colorScheme: ColorScheme.fromSwatch(
    backgroundColor: Colors.grey[200],
    cardColor: Colors.white,
  ), // Use the MaterialColor,
  dividerTheme: DividerThemeData(color: Colors.grey[300], thickness: 1),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black, // Button background
      backgroundColor: Colors.white, // Text and icon color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.black, // Text and icon color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textTheme: TextTheme(bodySmall: TextStyle(color: Colors.grey[600])),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 4),
    ),
  ),
);
