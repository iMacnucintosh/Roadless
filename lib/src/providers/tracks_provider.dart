import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/models/track.dart';

class TracksNotifier extends StateNotifier<List<Track>> {
  TracksNotifier(this.ref) : super([]) {
    _initializeRules();
  }

  final Ref ref;
  Track? previousTrack;

  void _initializeRules() async {
    // File trackFile = File('assets/tracks/track.gpx');
    // File burgalesaFile = File('assets/tracks/burgalesa.gpx');

    List<Track> dummyTracks = [];

    // String trackData = await trackFile.readAsString();
    // List<LatLng> points = getTrackPoints(trackData);

    // String burgalesaData = await burgalesaFile.readAsString();
    // List<LatLng> burgalesaPoints = getTrackPoints(burgalesaData);

    // Track track = Track(
    //   id: const Uuid().v4(),
    //   name: getTrackName(trackData),
    //   trackData: trackData,
    //   points: points,
    //   waypoints: getTrackwaypoints(trackData),
    //   distance: calculateTrackDistance(points),
    // );

    // Track burgalesa = Track(
    //   id: const Uuid().v4(),
    //   name: getTrackName(burgalesaData),
    //   trackData: trackData,
    //   points: burgalesaPoints,
    //   waypoints: getTrackwaypoints(burgalesaData),
    //   distance: calculateTrackDistance(burgalesaPoints),
    // );

    // dummyTracks.add(track);
    // dummyTracks.add(burgalesa);
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
