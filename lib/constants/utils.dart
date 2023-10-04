import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/constants/map_providers.dart';

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

Future<List<LatLng>> loadTrack(MapController mapController, bool downloadIntoCache) async {
  File? trackFile = await pickFile();
  if (trackFile != null) {
    String? track = await trackFile.readAsString();

    var xmlGpx = GpxReader().fromString(track);

    List<LatLng> points = getTrackPoints(xmlGpx);

    if (downloadIntoCache) {
      downloadTrackIntoCache(points);
    }

    return points;
  } else {
    return [];
  }
}

getTrackPoints(Gpx track) {
  List<LatLng> points = [];
  List<Wpt> wptPoints = [];
  if (track.rtes.isNotEmpty) {
    wptPoints = track.rtes.first.rtepts;
  } else if (track.trks.isNotEmpty) {
    wptPoints = track.trks.first.trksegs.first.trkpts;
  }

  for (Wpt point in wptPoints) {
    points.add(LatLng(point.lat!, point.lon!));
  }

  return points;
}

Future<void> downloadTrackIntoCache(List<LatLng> points) async {
  var cachedImages = [];
  for (LatLng point in points) {
    List coordinates = getXY(15, point);
    String tileUrl =
        '${mapProviderUrls["OpenStreetMap"]!}/6/${coordinates[0]}/${coordinates[1]}.png';
    //  String tileUrl =
    //     '${mapProviderUrls["OpenStreetMap"]!}/4/8/7.png';
    cachedImages.add(
      CachedNetworkImage(
        imageUrl: tileUrl,   
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
  print(cachedImages);
}
