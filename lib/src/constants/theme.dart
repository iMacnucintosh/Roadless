import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, surfaceContainer: Colors.grey[200]),
  useMaterial3: true,
  textTheme: GoogleFonts.nunitoTextTheme(),
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return lightTheme.colorScheme.primaryContainer;
          }
          return lightTheme.colorScheme.onPrimary;
        },
      ),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.blue, surfaceContainer: Colors.black),
  useMaterial3: true,
  textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return darkTheme.colorScheme.primaryContainer;
          }
          return darkTheme.colorScheme.onSecondary;
        },
      ),
    ),
  ),
);
