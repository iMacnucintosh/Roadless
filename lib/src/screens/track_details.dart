import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:roadless/src/models/track.dart';

class TrackDetailsScreen extends StatefulWidget {
  final Track track;

  const TrackDetailsScreen({super.key, required this.track});

  @override
  TrackDetailsScreenState createState() => TrackDetailsScreenState();
}

class TrackDetailsScreenState extends State<TrackDetailsScreen> {
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
                  initialZoom: widget.track.fitBounds(trackBounds, constraints.biggest),
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
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${widget.track.distance} km',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
