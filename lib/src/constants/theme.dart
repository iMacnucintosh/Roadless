import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, surfaceContainer: Colors.grey[200]),
  useMaterial3: true,
  textTheme: GoogleFonts.nunitoTextTheme(),
);

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.blue, surfaceContainer: Colors.black),
  useMaterial3: true,
  textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
);
