// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';
import 'package:roadless/src/providers/theme_provider.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:roadless/src/screens/track_details.dart';
import 'package:roadless/src/screens/new_track.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    final sharedPreferences = ref.watch(sharedPreferencesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text("Roadless"),
        actions: [
          Switch(
            value: ref.watch(isDarkModeProvider),
            onChanged: (value) {
              sharedPreferences.setBool("is_dark_mode", value);
              ref.read(isDarkModeProvider.notifier).update((state) => value);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: tracks.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 5,
                  );
                },
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(tracks[index].id),
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
                      ref.read(tracksProvider.notifier).removeTrack(tracks[index]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${tracks[index].name} eliminada")),
                      );
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackDetailsScreen(
                              track: tracks[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tracks[index].name),
                                  Text(
                                    tracks[index].id,
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                                  )
                                ],
                              ),
                            ),
                            if (Theme.of(context).colorScheme.brightness == Brightness.light)
                              if (tracks[index].imageLight != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  child: Image.memory(
                                    height: 60,
                                    tracks[index].imageLight!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            if (Theme.of(context).colorScheme.brightness == Brightness.dark)
                              if (tracks[index].imageDark != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  child: Image.memory(
                                    height: 60,
                                    tracks[index].imageDark!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                          ],
                        ),
                        // title: Text(tracks[index].name),
                        // subtitle: Text(
                        //   tracks[index].id,
                        //   style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                        // ),
                        // trailing: Theme.of(context).colorScheme.brightness == Brightness.light
                        //     ? tracks[index].imageLight != null
                        //         ? Image.memory(
                        //             tracks[index].imageLight!,
                        //             fit: BoxFit.cover,
                        //           )
                        //         : null
                        //     : tracks[index].imageDark != null
                        //         ? Image.memory(
                        //             tracks[index].imageDark!,
                        //             fit: BoxFit.cover,
                        //           )
                        //         : null,
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(10.0),
                        // ),
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => TrackDetailsScreen(
                        //         track: tracks[index],
                        //       ),
                        //     ),
                        //   );
                        // },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Añadir track",
        onPressed: () async {
          String? trackData = await Track.loadTrackData();

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
