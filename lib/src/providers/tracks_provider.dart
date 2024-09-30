import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/cloud_firestore_provider.dart';

class TracksNotifier extends StateNotifier<List<Track>> {
  TracksNotifier(this.ref) : super([]) {
    getTracksFromFirestore();
  }

  final Ref ref;

  void getTracksFromFirestore() async {
    state = await ref.read(cloudFirestoreProvider.notifier).getTracks();
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

  List<Track> deleteTrack(Track track) {
    ref.read(cloudFirestoreProvider.notifier).deleteTrack(track.id);

    final tracks = List<Track>.from(state);
    tracks.remove(track);
    state = tracks;
    return state;
  }

  void clearTracks() {
    state = [];
  }
}

final tracksProvider = StateNotifierProvider<TracksNotifier, List<Track>>((ref) {
  return TracksNotifier(ref);
});

final tracksFilterProvider = StateProvider<String>((ref) {
  return "all";
});

class FilteredTracksByActivityNotifier extends StateNotifier<List<Track>> {
  FilteredTracksByActivityNotifier(this.ref) : super([]) {
    filterTracksByActivity();
  }

  final Ref ref;

  void filterTracksByActivity() {
    List<Track> tracks = ref.watch(tracksProvider);
    String currentFilter = ref.watch(tracksFilterProvider);
    if (currentFilter != "all") {
      state =  tracks.where((track) => track.activityType?.name == currentFilter).toList();
    } else {
      state = tracks;
    }
  }
}

final filteredTracksByActivityProvider = StateNotifierProvider<FilteredTracksByActivityNotifier, List<Track>>((ref) {
  return FilteredTracksByActivityNotifier(ref);
});
