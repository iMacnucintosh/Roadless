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
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.all(12),
    fillColor: ColorScheme.fromSeed(seedColor: Colors.blue, surfaceContainer: Colors.grey[200]).onSecondary,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey[200]!,
        width: 1.4,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: ColorScheme.fromSeed(seedColor: Colors.blue, surfaceContainer: Colors.grey[200]).primary,
        width: 3,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
        width: 3,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
        width: 3,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    prefixIconColor: WidgetStateColor.resolveWith(
      (states) => resolveInputColor(states),
    ),
    suffixStyle: const TextStyle(),
  ),
);

@override
Color resolveInputColor(Set<WidgetState> states) {
  if (states.contains(WidgetState.focused)) {
    return Colors.blue;
  }
  return Colors.grey;
}

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
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.all(12),
    fillColor: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.blue, surfaceContainer: Colors.black).onSecondary,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey[200]!,
        width: 1.4,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.blue, surfaceContainer: Colors.black).primary,
        width: 3,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
        width: 3,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
        width: 3,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    prefixIconColor: WidgetStateColor.resolveWith(
      (states) => resolveInputColor(states),
    ),
    suffixStyle: const TextStyle(),
  ),
);
