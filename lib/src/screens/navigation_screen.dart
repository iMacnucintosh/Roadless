import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  NavigationScreenState createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  late bool _navigationMode;
  late int _pointerCount;
  late AlignOnUpdate _alignPositionOnUpdate;
  late AlignOnUpdate _alignDirectionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;
  late final StreamController<void> _alignDirectionStreamController;

  @override
  void initState() {
    super.initState();
    _navigationMode = false;
    _pointerCount = 0;
    _alignPositionOnUpdate = AlignOnUpdate.never;
    _alignDirectionOnUpdate = AlignOnUpdate.never;
    _alignPositionStreamController = StreamController<double?>();
    _alignDirectionStreamController = StreamController<void>();
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    _alignDirectionStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(41.652251, -4.724532),
            initialZoom: 10,
            minZoom: 4,
            maxZoom: 19,
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerUp,
          ),
          // ignore: sort_child_properties_last
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: CancellableNetworkTileProvider(),
              maxZoom: 19,
            ),
            CurrentLocationLayer(
              focalPoint: const FocalPoint(
                ratio: Point(0.0, 1.0),
                offset: Point(0.0, -60.0),
              ),
              alignPositionStream: _alignPositionStreamController.stream,
              alignDirectionStream: _alignDirectionStreamController.stream,
              alignPositionOnUpdate: _alignPositionOnUpdate,
              alignDirectionOnUpdate: _alignDirectionOnUpdate,
              style: const LocationMarkerStyle(
                marker: DefaultLocationMarker(
                  child: Icon(
                    Icons.navigation,
                    color: Colors.white,
                  ),
                ),
                markerSize: Size(40, 40),
                markerDirection: MarkerDirection.heading,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  backgroundColor: _navigationMode ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    setState(
                      () {
                        _navigationMode = !_navigationMode;
                        _alignPositionOnUpdate = _navigationMode ? AlignOnUpdate.always : AlignOnUpdate.never;
                        _alignDirectionOnUpdate = _navigationMode ? AlignOnUpdate.always : AlignOnUpdate.never;
                      },
                    );
                    if (_navigationMode) {
                      _alignPositionStreamController.add(18);
                      _alignDirectionStreamController.add(null);
                    }
                  },
                  child: const Icon(
                    Icons.navigation_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Disable align position and align direction temporarily when user is
  // manipulating the map.
  void _onPointerDown(e, l) {
    _pointerCount++;
    setState(() {
      _alignPositionOnUpdate = AlignOnUpdate.never;
      _alignDirectionOnUpdate = AlignOnUpdate.never;
    });
  }

  // Enable align position and align direction again when user manipulation
  // ended.
  void _onPointerUp(e, l) {
    if (--_pointerCount == 0 && _navigationMode) {
      setState(() {
        _alignPositionOnUpdate = AlignOnUpdate.always;
        _alignDirectionOnUpdate = AlignOnUpdate.always;
      });
      _alignPositionStreamController.add(18);
      _alignDirectionStreamController.add(null);
    }
  }
}
