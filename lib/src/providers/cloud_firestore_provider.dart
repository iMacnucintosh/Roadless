import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreNotifier extends StateNotifier<FirebaseFirestore> {
  CloudFirestoreNotifier(this.ref) : super(FirebaseFirestore.instance);

  final Ref ref;
}

final cloudFirestoreProvider = StateNotifierProvider<CloudFirestoreNotifier, FirebaseFirestore>((ref) {
  return CloudFirestoreNotifier(ref);
});
