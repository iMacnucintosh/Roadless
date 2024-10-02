import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/providers/google_auth_provider.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';
import 'package:roadless/src/providers/theme_provider.dart';

class RoadlessAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const RoadlessAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(googleUserProvider);
    final sharedPreferences = ref.watch(sharedPreferencesProvider);

    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () {
            bool newThemeStyle = !ref.read(isDarkModeProvider);
            sharedPreferences.setBool("is_dark_mode", newThemeStyle);
            ref.read(isDarkModeProvider.notifier).update((state) => newThemeStyle);
          },
          icon: ref.read(isDarkModeProvider) ? const Icon(Icons.light_mode_outlined) : const Icon(Icons.dark_mode_outlined),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: SizedBox(
                      width: 500,
                      child: Text(user.displayName!, style: Theme.of(context).textTheme.titleLarge),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Image.network(
                                  user.photoURL ?? "",
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.account_circle_outlined,
                                    size: 64,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(user.email ?? "", style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  signOutFromGoogle(ref);
                                  ref.read(googleUserProvider.notifier).update((state) => null);
                                  sharedPreferences.setBool("is_google_sign_in", false);
                                  ref.read(isGoogleSignInProvider.notifier).update((state) => false);
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cerrar sesión"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: user!.photoURL != null
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        user.photoURL ?? "",
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.account_circle_outlined),
                      ),
                    ),
                  )
                : Icon(Icons.account_circle_outlined),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
