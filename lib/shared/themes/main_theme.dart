import 'package:flutter/material.dart';

const textColor = Colors.black;

ThemeData mainTheme = ThemeData(
  // Define the primary swatch
  colorScheme: ColorScheme.fromSwatch(
    backgroundColor: Colors.grey[300],
    cardColor: Colors.white,
  ), // Use the MaterialColor,
  dividerTheme: DividerThemeData(color: Colors.grey[400], thickness: 1),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black, // Button background
      backgroundColor: Colors.white, // Text and icon color
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.black, // Text and icon color
    ),
  ),
  textTheme: TextTheme(),
);
