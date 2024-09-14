import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signInSilently();

  if (googleUser != null) {
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } else {
    // Handle sign-in cancellation
    throw 'Google sign-in cancelled';
  }
}

Future<void> signOutFromGoogle() async {
  await FirebaseAuth.instance.signOut();
}

final googleUserProvider = StateProvider<User?>((ref) {
  User? user;
  return user;
});

final isGoogleSignInProvider = StateProvider<bool>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return sharedPreferences.getBool("is_google_sign_in") ?? false;
});
