import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:uuid/uuid.dart';

class NewTrackScreen extends ConsumerWidget {
  const NewTrackScreen({super.key, required this.trackData});

  final String trackData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final boundaryKey = GlobalKey();
    List<LatLng> points = Track.getTrackPoints(trackData);
    TextEditingController nameController = TextEditingController(text: Track.getTrackName(trackData));
    MapController mapController = MapController();
    LatLngBounds trackBounds = Track.getBoundsFromTrackData(trackData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo track'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Nombre del track';
                    }
                    return null;
                  },
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight / 3,
                  child: RepaintBoundary(
                    key: boundaryKey,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: trackBounds.center,
                        initialZoom: Track.fitBoundsFromTrackData(trackBounds, constraints.biggest),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                          maxZoom: 19,
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: points,
                              strokeWidth: 6,
                              color: Colors.blue,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Anadir track",
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final byteData = await image.toByteData(format: ImageByteFormat.png);
            Uint8List trackImage = byteData!.buffer.asUint8List();

            final track = Track(
              id: const Uuid().v4(),
              name: nameController.text,
              trackData: trackData,
              points: points,
              image: trackImage,
            );
            ref.read(tracksProvider.notifier).addTrack(track);
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
