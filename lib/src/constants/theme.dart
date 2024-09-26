import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey);
ColorScheme darkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Colors.blue,
);

ThemeData lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  useMaterial3: true,
  textTheme: GoogleFonts.nunitoTextTheme(),
  segmentedButtonTheme: const SegmentedButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.all(12),
    filled: true,
    enabledBorder: _buildInputBorder(lightColorScheme.outline),
    focusedBorder: _buildInputBorder(lightColorScheme.primary),
    errorBorder: _buildInputBorder(lightColorScheme.error),
    focusedErrorBorder: _buildInputBorder(lightColorScheme.error),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
);

ThemeData darkTheme = lightTheme.copyWith(
  colorScheme: darkColorScheme,
  textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
  iconTheme: const IconThemeData(color: Colors.white),
);

OutlineInputBorder _buildInputBorder(Color color) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: color),
    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
  );
}
