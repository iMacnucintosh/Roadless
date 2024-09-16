import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/constants/enums.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/cloud_firestore_provider.dart';

class TrackDetailsScreen extends ConsumerStatefulWidget {
  final Track track;
  const TrackDetailsScreen({super.key, required this.track});

  @override
  TrackDetailsScreenState createState() => TrackDetailsScreenState();
}

class TrackDetailsScreenState extends ConsumerState<TrackDetailsScreen> {
  late MapController _mapController;
  late LatLngBounds trackBounds;

  @override
  void initState() {
    _mapController = MapController();
    trackBounds = widget.track.getBounds();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.track.name),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: trackBounds.center,
                  initialZoom: widget.track.fitBounds(trackBounds, Size(constraints.maxWidth, constraints.maxHeight - 200)),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    maxZoom: 19,
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.track.points,
                        strokeWidth: 6,
                        color: widget.track.color,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: widget.track.waypoints
                        .map(
                          (waypoint) => Marker(
                            width: 80.0,
                            height: 80.0,
                            point: waypoint.location,
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LayoutBuilder(builder: (context, constraints) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              const SizedBox(width: 100, child: Divider()),
                                              SizedBox(
                                                width: constraints.maxWidth,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(waypoint.name, style: Theme.of(context).textTheme.titleLarge),
                                                      const SizedBox(height: 10),
                                                      Text(waypoint.description == "" ? "Sin descripción" : waypoint.description),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    });
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  direction: Axis.vertical,
                  spacing: 5,
                  children: [
                    Text(
                      '${widget.track.distance} km',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        widget.track.activityType == null
                            ? InkWell(
                                onTap: () async {
                                  ActivityType? activityType = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: SingleChildScrollView(
                                          child: Center(
                                            child: Wrap(
                                              spacing: 20,
                                              runSpacing: 20,
                                              alignment: WrapAlignment.center,
                                              children: ActivityType.values
                                                  .map(
                                                    (activityType) => IconButton(
                                                      tooltip: activityType.label,
                                                      icon: Icon(
                                                        activityType.icon,
                                                        size: 40,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop(activityType);
                                                      },
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  if (activityType != null) {
                                    widget.track.activityType = activityType;
                                    ref.read(cloudFirestoreProvider.notifier).updateTrack(widget.track);
                                    setState(() {});
                                  }
                                },
                                child: const Text("Especificar actividad"),
                              )
                            : Row(
                                children: [
                                  Icon(widget.track.activityType!.icon),
                                  const SizedBox(width: 5),
                                  Text(widget.track.activityType!.label, style: Theme.of(context).textTheme.titleMedium),
                                ],
                              ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
