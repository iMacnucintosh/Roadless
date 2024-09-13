import 'dart:io';
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

  void _initializeRules() async {
    File trackFile = File('assets/tracks/test_track.gpx');

    List<Track> dummyTracks = [];

    List<LatLng> points = Track.getTrackPoints(
      await trackFile.readAsString(),
    );
    String trackData = await trackFile.readAsString();

    for (int i = 0; i < 20; i++) {
      Track track = Track(
        id: const Uuid().v4(),
        name: 'Test Track $i',
        trackData: trackData,
        points: points,
      );

      dummyTracks.add(track);
    }
    state = dummyTracks;
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
