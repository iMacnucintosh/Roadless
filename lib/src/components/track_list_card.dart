import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/Utils/logger.dart';
import 'package:roadless/src/Utils/utils.dart';
import 'package:roadless/src/components/public_tracks_marker.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/color_provider.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:roadless/src/screens/track_details_screen.dart';

class TrackListCard extends ConsumerWidget {
  const TrackListCard({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MapController mapController = MapController();
    return Dismissible(
      key: Key(track.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
        child: const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      onDismissed: (direction) {
        ref.read(tracksProvider.notifier).deleteTrack(track);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${track.name} eliminada")),
        );
      },
      child: Stack(
        children: [
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
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
                  logger.i("Ver si recargar estado");
                });
              },
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
                                      points: track.simplify(0.0015).map((e) => e.latLng).toList(),
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
          if (track.public)
            Positioned(
              right: -1,
              top: -1,
              child: Tooltip(
                message: "Pública",
                child: ClipPath(
                  clipper: PublicTracksMarker(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    width: 20,
                    height: 35,
                    child: Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
