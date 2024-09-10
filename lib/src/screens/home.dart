// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:roadless/src/screens/map.dart';
import 'package:roadless/src/screens/new_track.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
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
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(tracks[index].name),
                      subtitle: Text(
                        tracks[index].id,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              track: tracks[index],
                            ),
                          ),
                        );
                      },
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
