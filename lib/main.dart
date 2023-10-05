import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/components/loading_spinner.dart';
import 'package:roadless/controllers/track_controller.dart';
import 'package:roadless/providers/my_tile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

import 'constants/map_providers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final mapController = MapController();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roadless',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Map Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MapController mapController = MapController();
  TrackController trackController = TrackController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  LatLng initialMapPosition = const LatLng(41.645838, -4.730120);
  LatLng currentPosition = const LatLng(41.645838, -4.730120);
  double lastZoom = 16;
  List<Polyline> trackPoints = List.empty();
  bool isLoading = false;
  late Future<String> lastTrack;
  FollowOnLocationUpdate followLocation = FollowOnLocationUpdate.never;
  TurnOnHeadingUpdate turnOnHeading = TurnOnHeadingUpdate.never;

  @override
  initState() {
    super.initState();
    Wakelock.enable();
    // Timer.periodic(const Duration(seconds: 2), (timer) async {
    //   currentPosition = await locationController.getCurrentPosition();
    //   mapController.move(currentPosition, lastZoom);
    //   setState(() {
    //     currentPosition = currentPosition;
    //     print(currentPosition);
    //   });
    // });

    _prefs.then((SharedPreferences prefs) async {
      String track = prefs.getString('last_track') ?? "";
      if (track.isNotEmpty) {
        List<LatLng> points = await trackController.loadTrackFromString(track);
        if (points.isNotEmpty) {
          setState(
            () {
              trackPoints = [
                Polyline(
                  points: points,
                  color: Colors.blueAccent,
                  strokeWidth: 3,
                ),
              ];
              isLoading = false;
            },
          );
        }
      }
    });

    mapController.mapEventStream.listen((event) {
      lastZoom = event.zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    String mapProviderUrl = mapProviderUrls["OpenStreetMap"]!;

    final myTileProvider = MyTileProvider(
      baseUrl: mapProviderUrl,
    );

    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: initialMapPosition,
              zoom: 10,
              minZoom: 0,
              maxZoom: 18,
              onTap: (TapPosition tapPosition, LatLng latLng) {
                num n = pow(2, mapController.zoom.toInt());
                double xtile = n * ((mapController.center.longitude + 180) / 360);
                double ytile = n *
                    (1 -
                        (log(tan(mapController.center.latitudeInRad) +
                                acos(mapController.center.latitudeInRad)) /
                            pi)) /
                    2;
                try {
                  CachedNetworkImageProvider(
                      "https://tile.openstreetmap.org/${mapController.zoom.toInt()}/$xtile/$ytile.png");
                } on Exception catch (e) {
                  print(e);
                }
              },
            ),
            mapController: mapController,
            children: [
              TileLayer(
                urlTemplate: '$mapProviderUrl/{z}/{x}/{y}.png',
                tileProvider: myTileProvider,
              ),
              CurrentLocationLayer(
                followOnLocationUpdate: followLocation,
                turnOnHeadingUpdate: turnOnHeading,
              ),
              PolylineLayer(
                polylines: trackPoints,
              ),
            ],
          ),
          isLoading ? const LoadingSpinner() : Container()
        ],
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        spacing: 10,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (turnOnHeading == TurnOnHeadingUpdate.never) {
                  turnOnHeading = TurnOnHeadingUpdate.always;
                } else {
                  turnOnHeading = TurnOnHeadingUpdate.never;
                }
              });
            },
            tooltip: 'Dirección',
            backgroundColor:
                turnOnHeading == TurnOnHeadingUpdate.always ? Colors.brown[300] : Colors.white,
            child: const Icon(
              Icons.compass_calibration_outlined,
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (followLocation == FollowOnLocationUpdate.never) {
                  followLocation = FollowOnLocationUpdate.always;
                } else {
                  followLocation = FollowOnLocationUpdate.never;
                }
              });
            },
            tooltip: 'Locate',
            backgroundColor:
                followLocation == FollowOnLocationUpdate.always ? Colors.blue : Colors.white,
            child: const Icon(
              Icons.my_location_rounded,
            ),
          ),
          FloatingActionButton(
            onPressed: () async {
              setState(
                () {
                  isLoading = true;
                },
              );
              List<LatLng> points = await trackController.loadTrack(mapController);
              if (points.isNotEmpty) {
                setState(
                  () {
                    trackPoints = [
                      Polyline(
                        points: points,
                        color: Colors.blueAccent,
                        strokeWidth: 3,
                      ),
                    ];
                    isLoading = false;
                  },
                );
              }
            },
            tooltip: 'Import File',
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.download,
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
