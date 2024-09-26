// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/Utils/logger.dart';
import 'package:roadless/src/components/input_field.dart';
import 'package:roadless/src/constants/enums.dart';
import 'package:roadless/src/models/location.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/cloud_firestore_provider.dart';
import 'package:roadless/src/providers/color_provider.dart';
import 'package:roadless/src/providers/google_auth_provider.dart';
import 'package:roadless/src/providers/loading_provider.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:roadless/src/Utils/utils.dart';
import 'package:uuid/uuid.dart';

class NewTrackScreen extends ConsumerStatefulWidget {
  const NewTrackScreen({super.key, required this.trackData});
  final String trackData;

  @override
  NewTrackScreenState createState() => NewTrackScreenState();
}

class NewTrackScreenState extends ConsumerState<NewTrackScreen> {
  ActivityType? selectedActivityType;

  late Color dialogPickerColor;
  final formKey = GlobalKey<FormState>();
  MapController mapController = MapController();

  late List<Location> locations;
  late TextEditingController nameController;
  late LatLngBounds trackBounds;

  @override
  void initState() {
    locations = getTrackPoints(widget.trackData);
    nameController = TextEditingController(text: getTrackName(widget.trackData));
    trackBounds = getBoundsFromTrackData(widget.trackData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dialogPickerColor = ref.watch(colorProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo track'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return Column(
                    children: [
                      InputField(
                        prefixIcon: Icons.description,
                        controller: nameController,
                        labelText: "Nombre del track",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Introduzca un nombre para el track";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text("Color: "),
                              ColorIndicator(
                                width: 80,
                                height: 45,
                                borderRadius: 30,
                                color: dialogPickerColor,
                                onSelectFocus: false,
                                onSelect: () async {
                                  final Color colorBeforeDialog = dialogPickerColor;
                                  if (!(await colorPickerDialog(context, dialogPickerColor, ref))) {
                                    dialogPickerColor = colorBeforeDialog;
                                  }
                                },
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
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
                                    selectedActivityType = activityType;
                                    setState(() {});
                                  }
                                },
                                child: selectedActivityType == null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.outline,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          "Especificar actividad",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Icon(selectedActivityType!.icon),
                                            const SizedBox(width: 5),
                                            Text(selectedActivityType!.label, style: Theme.of(context).textTheme.titleMedium),
                                          ],
                                        ),
                                      ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight / 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          child: FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: trackBounds.center,
                              initialZoom: fitBoundsFromTrackData(trackBounds, Size(constraints.maxWidth, constraints.maxHeight / 2)),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                tileProvider: CancellableNetworkTileProvider(),
                                maxZoom: 19,
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: locations.map((location) => location.latLng).toList(),
                                    strokeWidth: 6,
                                    color: dialogPickerColor,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: getTrackwaypoints(widget.trackData)
                                    .map(
                                      (waypoint) => Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: waypoint.location.latLng,
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: ctx,
                                              builder: (BuildContext context) {
                                                return LayoutBuilder(
                                                  builder: (context, constraints) {
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
                                                  },
                                                );
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Card(
                    child: SizedBox(
                      width: 300,
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Añadir track",
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            ref.read(isLoadingProvider.notifier).state = true;
            final track = Track(
              id: const Uuid().v4(),
              name: nameController.text,
              locations: locations,
              waypoints: getTrackwaypoints(widget.trackData),
              color: dialogPickerColor,
              distance: calculateTrackDistance(locations.map((e) => e.latLng).toList()),
              activityType: selectedActivityType,
            );

            ref.read(tracksProvider.notifier).addTrack(track);

            final firestore = ref.watch(cloudFirestoreProvider);
            final user = ref.watch(googleUserProvider);

            if (user != null) {
              try {
                CollectionReference tracksRef = firestore.collection('users').doc(user.uid).collection('tracks');

                DocumentReference trackDocRef = tracksRef.doc(track.id);

                await trackDocRef.set(track.toJson());
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No se ha podido guardar el track en la nube: $e")),
                );

                logger.e(e);
              }
            }
            ref.read(isLoadingProvider.notifier).state = false;
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
