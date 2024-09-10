import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';
import 'package:roadless/src/providers/theme_provider.dart';
import 'package:roadless/src/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    return MaterialApp(
      title: 'Roadless',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
