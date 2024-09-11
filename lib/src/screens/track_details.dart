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
      body: LayoutBuilder(
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
                    color: Colors.blue,
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
