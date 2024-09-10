import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
  ),
  useMaterial3: true,
  textTheme: GoogleFonts.robotoTextTheme(),
);

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.blue,
  ),
  useMaterial3: true,
  textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
);
