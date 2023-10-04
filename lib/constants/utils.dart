import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';

List<double> getXY(MapController mapController) {
  num n = pow(2, mapController.zoom.toInt());
  double xtile = n * ((mapController.center.longitude + 180) / 360);
  double ytile = n *
      (1 -
          (log(tan(mapController.center.latitudeInRad) +
                  acos(mapController.center.latitudeInRad)) /
              pi)) /
      2;
  return [xtile.toInt().toDouble(), ytile.toInt().toDouble()];
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

Future<List<LatLng>> loadTrack(MapController mapController) async {
  File? trackFile = await pickFile();
  if (trackFile != null) {
    String? track = await trackFile.readAsString();

    var xmlGpx = GpxReader().fromString(track);

    List<LatLng> points = getTrackPoints(xmlGpx);
    return points;
  } else {
    return [];
  }
}

getTrackPoints(Gpx track) {
  List<LatLng> points = [];
  for (Wpt point in track.rtes[0].rtepts) {
    points.add(LatLng(point.lat!, point.lon!));
  }
  return points;
}
