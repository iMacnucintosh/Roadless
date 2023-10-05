import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/constants/utils.dart';

class TrackController {
  Future<List<LatLng>> loadTrack(MapController mapController) async {
    File? trackFile = await pickFile();
    if (trackFile != null) {
      String? track = await trackFile.readAsString();

      var xmlGpx = GpxReader().fromString(track);

      List<LatLng> points = getTrackPoints(xmlGpx);

      // Save track into storage
      final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      final SharedPreferences preferences = await prefs;
      preferences.setString("last_track", track);

      return points;
    } else {
      return [];
    }
  }

  Future<List<LatLng>> loadTrackFromString(String track) async {
    var xmlGpx = GpxReader().fromString(track);

    List<LatLng> points = getTrackPoints(xmlGpx);

    // Save track into storage
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    final SharedPreferences preferences = await prefs;
    preferences.setString("last_track", track);

    return points;
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



// Future<void> downloadTrackIntoCache(List<LatLng> points) async {
//   var cachedImages = [];
//   for (LatLng point in points) {
//     List coordinates = getXY(15, point);
//     String tileUrl =
//         '${mapProviderUrls["OpenStreetMap"]!}/6/${coordinates[0]}/${coordinates[1]}.png';
//     //  String tileUrl =
//     //     '${mapProviderUrls["OpenStreetMap"]!}/4/8/7.png';
//     cachedImages.add(
//       CachedNetworkImage(
//         imageUrl: tileUrl,
//         imageBuilder: (context, imageProvider) => Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             image: DecorationImage(
//               image: imageProvider,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   print(cachedImages);
// }