// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/components/track_list_card.dart';
import 'package:roadless/src/constants/enums.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:roadless/src/screens/add_track_screen.dart';
import 'package:roadless/src/Utils/utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(filteredTracksByActivityProvider);

    final tracksFilter = ref.watch(tracksFilterProvider);

    return Padding(
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
                return TrackListCard(track: tracks[index]);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                tooltip: "Añadir track",
                onPressed: () async {
                  String? trackData = await loadTrackData();

                  if (trackData != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTrackScreen(trackData: trackData),
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
            ],
          ),
        ],
      ),
    );
  }
}
