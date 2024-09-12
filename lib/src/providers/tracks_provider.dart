import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';

class TracksNotifier extends StateNotifier<List<Track>> {
  TracksNotifier(this.ref) : super([]) {
    // _initializeRules();
  }

  final Ref ref;
  Track? previousTrack;

  void _initializeRules() {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    String? tracksList = sharedPreferences.getString("tracks");
    if (tracksList != null) {
      List<String> tracksData = List<String>.from(jsonDecode(tracksList));
      List<Track> track = tracksData
          .map(
            (e) => Track.fromJson(jsonDecode(e)),
          )
          .toList();
      state = track;
    }
  }

  List<Track> getTracks() {
    return state;
  }

  List<Track> addTrack(Track track) {
    final tracks = List<Track>.from(state);
    tracks.add(track);
    state = tracks;
    return state;
  }

  List<Track> removeTrack(Track track) {
    final tracks = List<Track>.from(state);
    tracks.remove(track);
    state = tracks;
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
