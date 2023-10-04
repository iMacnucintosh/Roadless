import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/providers/my_tile_provider.dart';

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
      title: 'Flutter Demo',
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
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    String mapProviderUrl = mapProviderUrls["OpenStreetMap"]!;
    MapController mapController = MapController();

    final myTileProvider = MyTileProvider(
      baseUrl: mapProviderUrl,
    );

    List<double> getXY(LatLng latLong) {
      num n = pow(2, mapController.zoom.toInt());
      double xtile = n * ((mapController.center.longitude + 180) / 360);
      double ytile = n *
          (1 -
              (log(tan(mapController.center.latitudeInRad) +
                      acos(mapController.center.latitudeInRad)) /
                  pi)) /
          2;
      return [xtile.toInt().toDouble(), ytile.toInt().toDouble()];
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(51.509364, -0.128928),
              zoom: 3.2,
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
              PolygonLayer(
                polygonCulling: true,
                polygons: [
                  Polygon(
                      points: [
                        LatLng(36.95, -9.5),
                        LatLng(42.25, -9.5),
                        LatLng(42.25, -6.2),
                        LatLng(36.95, -6.2),
                      ],
                      color: Colors.blue.withOpacity(0.2),
                      borderStrokeWidth: 1,
                      borderColor: Colors.blue,
                      isFilled: true),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      LatLng(38.73, -9.14), // Lisbon, Portugal
                      LatLng(51.50, -0.12), // London, United Kingdom
                      LatLng(52.37, 4.90), // Amsterdam, Netherlands
                    ],
                    color: Colors.green,
                    strokeWidth: 2,
                  ),
                ],
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(52.2677, 5.1689), // center of 't Gooi
                    radius: 5000,
                    useRadiusInMeter: true,
                    color: Colors.red.withOpacity(0.3),
                    borderColor: Colors.red.withOpacity(0.7),
                    borderStrokeWidth: 2,
                  )
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(51.509364, -0.128928),
                    width: 80,
                    height: 80,
                    builder: (context) => const Icon(
                      Icons.location_on_outlined,
                      color: Colors.pink,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<double> tl = getXY(mapController.bounds!.northWest);
          List<double> bl = getXY(mapController.bounds!.southWest);
          List<double> tr = getXY(mapController.bounds!.northEast);
          List<double> br = getXY(mapController.bounds!.southEast);
          print(tl.toString());
          print(bl.toString());
          print(tr.toString());
          print(br.toString());
        },
        tooltip: 'Locate',
        child: Icon(Icons.my_location_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
