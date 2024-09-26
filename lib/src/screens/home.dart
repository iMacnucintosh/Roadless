// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/constants/enums.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/color_provider.dart';
import 'package:roadless/src/providers/google_auth_provider.dart';
import 'package:roadless/src/providers/loading_provider.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';
import 'package:roadless/src/providers/theme_provider.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:roadless/src/screens/track_details.dart';
import 'package:roadless/src/screens/new_track.dart';
import 'package:roadless/src/Utils/utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    restoreGoogleSession(ref);
    final tracks = ref.watch(filteredTracksByActivityProvider);

    final user = ref.watch(googleUserProvider);

    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    final isLoading = ref.watch(isLoadingProvider);

    final tracksFilter = ref.watch(tracksFilterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text("Roadless"),
        actions: [
          IconButton(
            onPressed: () {
              bool newThemeStyle = !ref.read(isDarkModeProvider);
              sharedPreferences.setBool("is_dark_mode", newThemeStyle);
              ref.read(isDarkModeProvider.notifier).update((state) => newThemeStyle);
            },
            icon: ref.read(isDarkModeProvider) ? const Icon(Icons.light_mode_outlined) : const Icon(Icons.dark_mode_outlined),
          ),
          if (user != null)
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
                                    child: Image.network(user.photoURL ?? ""),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(user.email ?? "", style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
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
                child: Text(user.displayName!),
              ),
            ),
          if (user == null)
            IconButton(
              onPressed: () async {
                signInWithGoogle(ref);
              },
              icon: const Icon(Icons.login_outlined),
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SegmentedButton(
                  multiSelectionEnabled: false,
                  showSelectedIcon: false,
                  segments: [
                    const ButtonSegment(icon: Icon(Icons.clear_all_outlined), value: "all"),
                    ...ActivityType.values.map(
                      (e) => ButtonSegment(icon: Icon(e.icon), value: e.name, tooltip: e.label),
                    ),
                  ],
                  selected: {tracksFilter},
                  onSelectionChanged: (values) {
                    ref.read(tracksFilterProvider.notifier).state = values.first;
                    ref.read(filteredTracksByActivityProvider.notifier).filterTracksByActivity();
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: tracks.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 8,
                      );
                    },
                    itemBuilder: (context, index) {
                      MapController mapController = MapController();
                      Track track = tracks[index];
                      return Dismissible(
                        key: Key(track.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        onDismissed: (direction) {
                          ref.read(tracksProvider.notifier).deleteTrack(track);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${track.name} eliminada")),
                          );
                        },
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            ref.read(colorProvider.notifier).update((state) => track.color);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrackDetailsScreen(
                                  track: track,
                                ),
                              ),
                            ).then((value) {
                              setState(() {});
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 30.0, 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(track.name, style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${track.distance} km",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (track.activityType != null)
                                                  Row(
                                                    children: [
                                                      Tooltip(
                                                        message: track.activityType!.label,
                                                        child: Icon(track.activityType!.icon, color: Theme.of(context).colorScheme.primary),
                                                      ),
                                                      const SizedBox(width: 5),
                                                    ],
                                                  ),
                                                Row(
                                                  children: [
                                                    const Tooltip(
                                                      message: "Marcadores",
                                                      child: Icon(
                                                        Icons.location_on,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    Text("${track.waypoints.length}", style: Theme.of(context).textTheme.titleMedium),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                    child: Material(
                                      color: Theme.of(context).colorScheme.surface,
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(1),
                                            ],
                                            stops: const [0.0, 0.3],
                                          ).createShader(bounds);
                                        },
                                        blendMode: BlendMode.dstIn,
                                        child: IgnorePointer(
                                          child: FlutterMap(
                                            mapController: mapController,
                                            options: MapOptions(
                                              initialCenter: track.getBounds().center,
                                              initialZoom: fitBoundsFromTrackData(
                                                track.getBounds(),
                                                const Size(150, 100),
                                              ),
                                              interactionOptions: const InteractionOptions(
                                                flags: InteractiveFlag.none,
                                              ),
                                            ),
                                            children: [
                                              TileLayer(
                                                urlTemplate: Theme.of(context).colorScheme.brightness == Brightness.light
                                                    ? 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
                                                    : 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                                                tileProvider: CancellableNetworkTileProvider(),
                                                maxZoom: 19,
                                              ),
                                              PolylineLayer(
                                                polylines: [
                                                  Polyline(
                                                    points: track.points,
                                                    strokeWidth: 2,
                                                    color: track.color,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Card(
                    child: SizedBox(
                      width: 400,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Añadir track",
        onPressed: () async {
          String? trackData = await loadTrackData();

          if (trackData != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewTrackScreen(trackData: trackData),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al cargar el track'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
