import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/src/Utils/logger.dart';
import 'package:roadless/src/models/track.dart';
import 'package:roadless/src/providers/cloud_firestore_provider.dart';
import 'package:roadless/src/providers/color_provider.dart';
import 'package:roadless/src/providers/google_auth_provider.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:roadless/src/Utils/utils.dart';
import 'package:uuid/uuid.dart';

class NewTrackScreen extends ConsumerWidget {
  const NewTrackScreen({super.key, required this.trackData});

  final String trackData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late Color dialogPickerColor;
    dialogPickerColor = ref.watch(colorProvider);

    final formKey = GlobalKey<FormState>();
    List<LatLng> points = getTrackPoints(trackData);
    TextEditingController nameController = TextEditingController(text: getTrackName(trackData));
    MapController mapController = MapController();
    LatLngBounds trackBounds = getBoundsFromTrackData(trackData);
    Future<bool> colorPickerDialog() async {
      return ColorPicker(
        color: dialogPickerColor,
        onColorChanged: (Color color) {
          dialogPickerColor = color;
          ref.read(colorProvider.notifier).update((state) => color);
        },
        width: 40,
        height: 40,
        borderRadius: 4,
        spacing: 5,
        runSpacing: 5,
        wheelDiameter: 155,
        pickerTypeLabels: const {
          ColorPickerType.primary: "Primarios",
          ColorPickerType.accent: "Acento",
          ColorPickerType.wheel: "Selector",
        },
        pickerTypeTextStyle: Theme.of(context).textTheme.labelLarge,
        actionButtons: const ColorPickerActionButtons(
          dialogOkButtonLabel: "Aceptar",
          dialogCancelButtonLabel: "Cancelar",
        ),
        heading: Text(
          'Selecciona un Color',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subheading: Text(
          'Puedes seleccionar una variante',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        wheelSubheading: Text(
          'Selecciona un color y su variante',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        showMaterialName: true,
        showColorName: true,
        showColorCode: true,
        copyPasteBehavior: const ColorPickerCopyPasteBehavior(
          longPressMenu: true,
        ),
        materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
        colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
        colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
        colorCodePrefixStyle: Theme.of(context).textTheme.bodySmall,
        selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.both: false,
          ColorPickerType.primary: true,
          ColorPickerType.accent: true,
          ColorPickerType.bw: false,
          ColorPickerType.custom: true,
          ColorPickerType.wheel: true,
        },
      ).showPickerDialog(
        context,
        actionsPadding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo track'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nombre del track';
                      }
                      return null;
                    },
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Color: "),
                      ColorIndicator(
                        width: 55,
                        height: 32,
                        borderRadius: 30,
                        color: dialogPickerColor,
                        onSelectFocus: false,
                        onSelect: () async {
                          final Color colorBeforeDialog = dialogPickerColor;
                          if (!(await colorPickerDialog())) {
                            dialogPickerColor = colorBeforeDialog;
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight / 3,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: trackBounds.center,
                        initialZoom: fitBoundsFromTrackData(trackBounds, constraints.biggest),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: Theme.of(context).colorScheme.brightness == Brightness.light
                              ? 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
                              : 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                          maxZoom: 19,
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: points,
                              strokeWidth: 6,
                              color: dialogPickerColor,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Añadir track",
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            final track = Track(
              id: const Uuid().v4(),
              name: nameController.text,
              trackData: trackData,
              points: points,
              color: dialogPickerColor,
              distance: calculateTrackDistance(points),
            );

            ref.read(tracksProvider.notifier).addTrack(track);

            final firestore = ref.watch(cloudFirestoreProvider);
            final user = ref.watch(googleUserProvider);

            if (user != null) {
              final userFirestore = <String, dynamic>{"uuid": user.uid};
              try {
                await firestore.collection("users").add(userFirestore);
              } catch (e) {
                logger.e(e);
              }

              // CollectionReference tracksRef = firestore.collection('users').doc(user.uid).collection('tracks');

              // DocumentReference trackDocRef = tracksRef.doc(track.id);

              // await trackDocRef.set({"name": track.name});
            }
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
