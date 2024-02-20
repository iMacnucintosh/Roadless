import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:roadless/models/track.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/constants/utils.dart';

class TrackController {
  Future<Track?> loadTrack(MapController mapController) async {
    File? trackFile = await pickFile();
    if (trackFile != null) {
      String? trackData = await trackFile.readAsString();
      var xmlGpx = GpxReader().fromString(trackData);

      List<LatLng> points = getTrackPoints(xmlGpx);

      Track track = Track(
        name: "",
        color: Colors.blue,
        points: points,
      );

      // Save track into storage
      final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      final SharedPreferences preferences = await prefs;
      preferences.setString("last_track", json.encode(track.toJson()));

      return track;
    }
    return null;
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
}
