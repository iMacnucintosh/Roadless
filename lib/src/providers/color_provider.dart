import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorProvider = StateProvider<Color>((ref) {
  Color color =  Colors.blue;
  return color;
});