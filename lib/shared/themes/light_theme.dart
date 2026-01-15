import 'package:flutter/material.dart';

import 'themes.dart';

ThemeData lightTheme = ThemeData(
  // Define the primary swatch
  primarySwatch: primaryGreen, // Use the MaterialColor

  scaffoldBackgroundColor:
      primaryGreen[500], // Use a lighter shade for the background

  iconTheme: const IconThemeData(
    color: black, // Icons are still black
    size: 24.0,
  ),
  fontFamily: 'Poppins',
  buttonTheme: ButtonThemeData(
    shape: const CircleBorder(),
    buttonColor: black, // Dark buttons
    splashColor:
        primaryGreen[200], // A slightly darker green for the splash effect
    height: 56.0,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: black,
    foregroundColor: white,
  ),

  // font-displayLarge sa tailwind
  textTheme: const TextTheme(
    // Display styles
    displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    // Title styles
    titleLarge: TextStyle(fontSize: 24),
    titleMedium: TextStyle(fontSize: 18),
    titleSmall: TextStyle(fontSize: 16),
    // Body styles
    bodyLarge: TextStyle(fontSize: 20),
    bodyMedium: TextStyle(fontSize: 16),
    bodySmall: TextStyle(fontSize: 12),
    // Label styles
    labelLarge: TextStyle(fontSize: 14),
    labelMedium: TextStyle(fontSize: 12),
    labelSmall: TextStyle(fontSize: 10),
  ),

  cardTheme: CardThemeData(shape: cardShape, elevation: cardElevation),

  listTileTheme: ListTileThemeData(
    shape: cardShape,
    tileColor: white,
    contentPadding: cardMargin,
  ),

  dividerColor: Colors.transparent,

  appBarTheme: const AppBarTheme(
    color: Colors.transparent, // Apply the primary green to the AppBar
    iconTheme: IconThemeData(color: black),
    elevation: 0,
  ),
);
