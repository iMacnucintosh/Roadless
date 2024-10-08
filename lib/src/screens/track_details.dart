import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/Utils/utils.dart';
import 'package:roadless/src/components/altitude_chart.dart';
import 'package:roadless/src/components/input_field.dart';
import 'package:roadless/src/constants/enums.dart';
import 'package:roadless/src/models/location.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/models/waypoint.dart';
import 'package:roadless/src/providers/cloud_firestore_provider.dart';
import 'package:roadless/src/providers/color_provider.dart';
import 'package:roadless/src/providers/google_auth_provider.dart';

class TrackDetailsScreen extends ConsumerStatefulWidget {
  final Track track;
  const TrackDetailsScreen({super.key, required this.track});

  @override
  TrackDetailsScreenState createState() => TrackDetailsScreenState();
}

class TrackDetailsScreenState extends ConsumerState<TrackDetailsScreen> {
  late MapController _mapController;
  late LatLngBounds trackBounds;
  bool canEdit = false;
  @override
  void initState() {
    _mapController = MapController();
    trackBounds = widget.track.getBounds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color dialogPickerColor = ref.watch(colorProvider);
    TextEditingController nameController = TextEditingController(text: widget.track.name);
    canEdit = ref.watch(googleUserProvider)!.uid == widget.track.userUid;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              fillColor: Theme.of(context).colorScheme.surface,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  nameController.clear();
                },
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Introduzca un nombre para el track";
              }
              return null;
            },
            onEditingComplete: () {
              if (formKey.currentState!.validate()) {
                widget.track.name = nameController.text;
                ref.read(cloudFirestoreProvider.notifier).updateTrack(widget.track);
              }
            },
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: trackBounds.center,
                  initialZoom: widget.track.fitBounds(trackBounds, Size(constraints.maxWidth, constraints.maxHeight - 450)),
                  onTap: (tapPosition, point) {
                    showModalBottomSheet(
                      showDragHandle: true,
                      context: context,
                      builder: (BuildContext context) {
                        return LayoutBuilder(builder: (context, constraints) {
                          TextEditingController nameController = TextEditingController();
                          return SingleChildScrollView(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            InputField(
                                              controller: nameController,
                                              labelText: "Nombre",
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                FilledButton(
                                                  onPressed: () {
                                                    Waypoint waypoint = Waypoint(
                                                      name: nameController.text,
                                                      location: Location(latLng: point),
                                                    );
                                                    widget.track.waypoints.add(waypoint);
                                                    ref.read(cloudFirestoreProvider.notifier).updateTrack(widget.track);
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text("Guardar"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    );
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    tileProvider: CancellableNetworkTileProvider(),
                    maxZoom: 19,
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.track.locations.map((location) => location.latLng).toList(),
                        strokeWidth: 6,
                        color: dialogPickerColor,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: widget.track.waypoints
                        .map(
                          (waypoint) => Marker(
                            width: 80.0,
                            height: 80.0,
                            point: waypoint.location.latLng,
                            child: GestureDetector(
                              onTap: () {
                                TextEditingController nameController = TextEditingController(text: waypoint.name);
                                showModalBottomSheet(
                                  showDragHandle: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LayoutBuilder(builder: (context, constraints) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: constraints.maxWidth,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        InputField(
                                                          controller: nameController,
                                                          labelText: "Nombre",
                                                        ),
                                                        const SizedBox(height: 20),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            IconButton(
                                                              tooltip: "Eliminar marcador",
                                                              style: ButtonStyle(
                                                                backgroundColor: WidgetStateProperty.all(
                                                                  Colors.red,
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                widget.track.waypoints.remove(waypoint);
                                                                ref.read(cloudFirestoreProvider.notifier).updateTrack(widget.track);
                                                                setState(() {});
                                                                Navigator.pop(context);
                                                              },
                                                              icon: const Icon(
                                                                Icons.delete_outlined,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                            FilledButton(
                                                              onPressed: () {
                                                                waypoint.name = nameController.text;
                                                                ref.read(cloudFirestoreProvider.notifier).updateTrack(widget.track);
                                                                setState(() {});
                                                                Navigator.pop(context);
                                                              },
                                                              child: const Padding(
                                                                padding: EdgeInsets.all(8.0),
                                                                child: Text("Guardar"),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Card(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 8,
                      children: [
                        Text(
                          '${widget.track.distance} km',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: canEdit
                                  ? () async {
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
                                    }
                                  : null,
                              child: widget.track.activityType == null
                                  ? const Text("Especificar actividad")
                                  : Row(
                                      children: [
                                        Icon(widget.track.activityType!.icon),
                                        const SizedBox(width: 5),
                                        Text(widget.track.activityType!.label, style: Theme.of(context).textTheme.titleMedium),
                                      ],
                                    ),
                            )
                          ],
                        ),
                        Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ColorIndicator(
                              width: 55,
                              height: 32,
                              borderRadius: 30,
                              color: dialogPickerColor,
                              onSelectFocus: false,
                              onSelect: () async {
                                final Color colorBeforeDialog = dialogPickerColor;
                                if (!await colorPickerDialog(
                                  context,
                                  dialogPickerColor,
                                  ref,
                                  onColorChanged: (color) {
                                    widget.track.color = color;
                                    ref.read(cloudFirestoreProvider.notifier).updateTrack(widget.track);
                                  },
                                )) {
                                  dialogPickerColor = colorBeforeDialog;
                                }
                              },
                            ),
                            Tooltip(
                              message: "Público",
                              child: Icon(Icons.people),
                            ),
                            Checkbox(
                              value: widget.track.public,
                              onChanged: canEdit
                                  ? (value) {
                                      widget.track.public = value!;
                                      ref.read(cloudFirestoreProvider.notifier).updateTrack(widget.track);
                                      setState(() {});
                                    }
                                  : null,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  tooltip: "Exportar GPX",
                  onPressed: () async {
                    String trackData = widget.track.toGpx();
                    await FileSaver.instance.saveFile(
                      bytes: utf8.encode(trackData),
                      name: widget.track.name,
                      ext: "gpx",
                    );
                  },
                  child: const Icon(Icons.ios_share),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: AltitudeChart(
                  locations: widget.track.locations,
                  trackColor: widget.track.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
