import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      ),
      Track(
        id: const Uuid().v4(),
        name: "Ruta 2",
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
