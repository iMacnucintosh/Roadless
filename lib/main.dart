import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/controllers/track_controller.dart';
import 'package:roadless/models/track.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_controller/volume_controller.dart';

void main() {
  runApp(const Roadless());
}

class Roadless extends StatelessWidget {
  const Roadless({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roadless',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late bool _navigationMode;
  late int _pointerCount;
  double zoomLevel = 2;
  late AlignOnUpdate _alignPositionOnUpdate;
  late AlignOnUpdate _alignDirectionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;
  late final StreamController<void> _alignDirectionStreamController;

  late MapController _mapController;
  late TrackController _trackController;

  late List<Track> visibleTracks = List.empty(growable: true);
  late double _setVolumeValue;

  @override
  void initState() {
    super.initState();
    _navigationMode = false;
    _pointerCount = 0;
    _alignPositionOnUpdate = AlignOnUpdate.never;
    _alignDirectionOnUpdate = AlignOnUpdate.never;
    _alignPositionStreamController = StreamController<double?>();
    _alignDirectionStreamController = StreamController<void>();

    _mapController = MapController();
    _trackController = TrackController();

    VolumeController().listener((volume) {
      setState(() {
        if (volume < _setVolumeValue) {
          zoomLevel -= 1;
          _alignPositionStreamController.add(zoomLevel);
        } else if (volume > _setVolumeValue) {
          zoomLevel += 1;
          _alignPositionStreamController.add(zoomLevel);
        }
        _setVolumeValue = volume;
      });
    });

    VolumeController().getVolume().then((volume) => _setVolumeValue = volume);

    loadVisibleTracks();
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    _alignDirectionStreamController.close();

    VolumeController().removeListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roadless'),
        actions: [
          IconButton(
            onPressed: () async {
              Track? track = await _trackController.loadTrack(_mapController);
              if (track != null) {
                visibleTracks.clear();
                setState(() {
                  visibleTracks.add(track);
                });
              }
            },
            icon: const Icon(
              Icons.file_open_rounded,
            ),
          ),
          IconButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                File map = File(result.files.single.path!);
                print(map);
              }
            },
            icon: const Icon(
              Icons.map,
            ),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
            initialCenter: const LatLng(0, 0),
            initialZoom: zoomLevel,
            minZoom: 0,
            maxZoom: 19,
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerUp,
            onMapEvent: _onMapEvent),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'net.tlserver6y.flutter_map_location_marker.example',
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
          PolylineLayer(
            polylines: visibleTracks
                .map(
                  (track) => Polyline(
                    points: track.points,
                    strokeWidth: 6,
                    color: track.color,
                  ),
                )
                .toList(),
          ),
        ],
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        spacing: 10,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            onPressed: () {
              zoomLevel = 28;
              _alignPositionStreamController.add(zoomLevel);
            },
            child: const Icon(
              Icons.zoom_in_map_rounded,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            onPressed: () {
              zoomLevel += 1;
              _alignPositionStreamController.add(zoomLevel);
            },
            child: const Icon(
              Icons.zoom_in,
            ),
          ),
          FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 204, 72, 63),
            foregroundColor: Colors.white,
            onPressed: () {
              zoomLevel -= 1;
              _alignPositionStreamController.add(zoomLevel);
            },
            child: const Icon(
              Icons.zoom_out,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            backgroundColor: _navigationMode ? Colors.blue : Colors.grey,
            foregroundColor: Colors.white,
            onPressed: () {
              setState(
                () {
                  _navigationMode = !_navigationMode;
                  _alignPositionOnUpdate =
                      _navigationMode ? AlignOnUpdate.always : AlignOnUpdate.never;
                  _alignDirectionOnUpdate =
                      _navigationMode ? AlignOnUpdate.always : AlignOnUpdate.never;
                },
              );
              if (_navigationMode) {
                _alignPositionStreamController.add(zoomLevel);
                _alignDirectionStreamController.add(null);
              }
            },
            child: const Icon(
              Icons.navigation_outlined,
            ),
          ),
        ],
      ),
    );
  }

  void _onMapEvent(MapEvent mapEvent) {
    zoomLevel = mapEvent.camera.zoom;
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
      _alignPositionStreamController.add(zoomLevel);
      _alignDirectionStreamController.add(null);
    }
  }

  void loadVisibleTracks() {
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

    prefs.then((SharedPreferences prefs) async {
      if (prefs.getString('last_track') != null) {
        Track track = Track.fromJson(json.decode(prefs.getString('last_track')!));
        visibleTracks.add(track);
      }
    });
  }
}
