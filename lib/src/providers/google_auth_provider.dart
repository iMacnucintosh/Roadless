import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roadless/src/Utils/logger.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';

Future<UserCredential> signInWithGoogle(WidgetRef ref) async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signInSilently();

  if (googleUser != null) {
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Almacenar que el usuario ha iniciado sesión
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    await sharedPreferences.setBool("is_google_sign_in", true);

    // Actualizar el estado del provider
    ref.read(googleUserProvider.notifier).state = userCredential.user;

    return userCredential;
  } else {
    // Si no hay una sesión de Google previa, realizar el proceso normal de signIn
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Almacenar que el usuario ha iniciado sesión
      final sharedPreferences = ref.read(sharedPreferencesProvider);
      await sharedPreferences.setBool("is_google_sign_in", true);

      // Actualizar el estado del provider
      ref.read(googleUserProvider.notifier).state = userCredential.user;

      return userCredential;
    } else {
      throw 'Google sign-in cancelled';
    }
  }
}

/// Función para cerrar sesión
Future<void> signOutFromGoogle(WidgetRef ref) async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();

  // Limpiar el estado de autenticación
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  await sharedPreferences.setBool("is_google_sign_in", false);

  ref.read(googleUserProvider.notifier).state = null;
}

final googleUserProvider = StateProvider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

final isGoogleSignInProvider = StateProvider<bool>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return sharedPreferences.getBool("is_google_sign_in") ?? false;
});

Future<void> restoreGoogleSession(WidgetRef ref) async {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  final isGoogleSignIn = sharedPreferences.getBool("is_google_sign_in") ?? false;
  final googleUser = ref.watch(googleUserProvider);

  if (isGoogleSignIn && googleUser == null) {
    try {
      await signInWithGoogle(ref);
    } catch (e) {
      logger.e('Error restoring session: $e');
    }
  }
}
