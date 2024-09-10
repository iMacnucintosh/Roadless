import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/src/models/track.dart';
import 'package:uuid/uuid.dart';

class TracksNotifier extends StateNotifier<List<Track>> {
  TracksNotifier(this.ref) : super([]) {
    _initializeRules();
  }

  final Ref ref;
  Track? previousTrack;

  void _initializeRules() {
    state = [
      Track(
        id: const Uuid().v4(),
        name: "Ruta 1",
        points: const [
          LatLng(41.6523, -4.7233),
          LatLng(41.6531, -4.7222),
          LatLng(41.6542, -4.7211),
          LatLng(41.6553, -4.7199),
          LatLng(41.6564, -4.7187),
          LatLng(41.6575, -4.7175),
          LatLng(41.6586, -4.7163),
          LatLng(41.6597, -4.7151),
          LatLng(41.6608, -4.7139),
          LatLng(41.6619, -4.7127),
        ],
      ),
      Track(
        id: const Uuid().v4(),
        name: "Ruta 2",
        points: const [
          LatLng(41.6553, -4.7199),
          LatLng(41.6562, -4.7187),
          LatLng(41.6571, -4.7175),
          LatLng(41.6580, -4.7163),
          LatLng(41.6589, -4.7151),
          LatLng(41.6598, -4.7139),
          LatLng(41.6607, -4.7127),
          LatLng(41.6616, -4.7115),
          LatLng(41.6625, -4.7103),
          LatLng(41.6634, -4.7091),
        ],
      ),
    ];
  }

  List<Track> getTracks() {
    return state;
  }

  Track? getRandomTrack() {
    List<Track> tracks = getTracks();
    if (tracks.length > 1) {
      Track track = tracks[Random().nextInt(tracks.length)];
      while (previousTrack == track) {
        track = tracks[Random().nextInt(tracks.length)];
      }
      previousTrack = track;
      return track;
    } else {
      return null;
    }
  }
}

final tracksProvider = StateNotifierProvider<TracksNotifier, List<Track>>((ref) {
  return TracksNotifier(ref);
});
