import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadless/main.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/google_auth_provider.dart';

class CloudFirestoreNotifier extends StateNotifier<FirebaseFirestore> {
  CloudFirestoreNotifier(this.ref) : super(FirebaseFirestore.instance);

  final Ref ref;

  Future<List<Track>> getTracks() async {
    List<Track> tracks = [];
    final user = ref.watch(googleUserProvider);
    if (user != null) {
      QuerySnapshot userTracks = await state.collection("users").doc(user.uid).collection("tracks").get();
      for (var trackDoc in userTracks.docs) {
        Map<String, dynamic> trackData = trackDoc.data() as Map<String, dynamic>;
        Track track = Track.fromJson(trackData);
        tracks.add(track);
      }
    }
    return tracks;
  }

  Future<void> deleteTrack(String id) async {
    final user = ref.watch(googleUserProvider);
    if (user != null) {
      await state.collection("users").doc(user.uid).collection("tracks").doc(id).delete();
    }
  }

  Future<void> updateTrack(Track track) async {
    final user = ref.watch(googleUserProvider);
    if (user != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: LinearProgressIndicator()));
      await state.collection("users").doc(user.uid).collection("tracks").doc(track.id).update(track.toJson());
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text("Track actualizado")));
    }
  }
}

final cloudFirestoreProvider = StateNotifierProvider<CloudFirestoreNotifier, FirebaseFirestore>((ref) {
  return CloudFirestoreNotifier(ref);
});
