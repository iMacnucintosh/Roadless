import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/constants/map_providers.dart';
import 'package:roadless/controllers/track_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<int> getXY(int zoomLevel, LatLng point) {
  num n = pow(2, zoomLevel);
  double xtile = n * ((point.longitude + 180) / 360);
  double ytile = n * (1 - (log(tan(point.latitudeInRad) + acos(point.latitudeInRad)) / pi)) / 2;
  return [xtile.toInt(), ytile.toInt()];
}

Future<File?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  File? file;
  if (result != null) {
    file = File(result.files.single.path!);
  } else {
    // User canceled the picker
    return null;
  }
  return file;
}

