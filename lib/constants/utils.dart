import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';

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

