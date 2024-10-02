import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/firebase_options.dart';
import 'package:roadless/src/components/app_scaffold.dart';
import 'package:roadless/src/constants/theme.dart';
import 'package:roadless/src/providers/google_auth_provider.dart';
import 'package:roadless/src/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';
import 'package:roadless/src/providers/theme_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const Roadless(),
    ),
  );
}

class Roadless extends ConsumerWidget {
  const Roadless({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    restoreGoogleSession(ref);

    final user = ref.watch(googleUserProvider);

    return MaterialApp(
      title: 'Roadless',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: user != null ? const AppScaffold() : const LoginScreen(),
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}
