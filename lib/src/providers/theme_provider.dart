import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';

final isDarkModeProvider = StateProvider<bool>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return sharedPreferences.getBool("is_dark_mode") ?? false;
});
