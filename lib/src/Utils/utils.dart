import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/src/models/location.dart';
import 'package:roadless/src/models/waypoint.dart';
import 'package:roadless/src/providers/color_provider.dart';

Future<Uint8List?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
  if (result != null) {
    return result.files.first.bytes;
  } else {
    return null;
  }
}

Future<String?> loadTrackData() async {
  Uint8List? trackFile = await pickFile();
  if (trackFile != null) {
    return utf8.decode(trackFile);
  }
  return null;
}

List<Location> getTrackPoints(String trackData) {
  List<Location> trackPoints = [];
  List<Wpt> wpts = [];
  Gpx track = GpxReader().fromString(trackData);
  if (track.rtes.isNotEmpty) {
    wpts = track.rtes.first.rtepts;
  } else if (track.trks.isNotEmpty) {
    wpts = track.trks.first.trksegs.first.trkpts;
  }

  for (Wpt location in wpts) {
    trackPoints.add(
      Location(
        latLng: LatLng(location.lat!, location.lon!),
        elevation: location.ele ?? 0,
      ),
    );
  }

  return trackPoints;
}

List<Waypoint> getTrackwaypoints(String trackData) {
  List<Waypoint> waypoints = [];
  Gpx track = GpxReader().fromString(trackData);

  for (Wpt wpt in track.wpts) {
    waypoints.add(
      Waypoint(
        name: wpt.name ?? "",
        location: Location(
          latLng: LatLng(wpt.lat!, wpt.lon!),
          elevation: wpt.ele ?? 0,
        ),
      ),
    );
  }

  return waypoints;
}

String getTrackName(String trackData) {
  Gpx track = GpxReader().fromString(trackData);

  if (track.metadata == null) {
    return '';
  }
  return track.metadata!.name ?? "";
}

LatLngBounds getBoundsFromTrackData(String trackData) {
  List<Location> locations = getTrackPoints(trackData);
  double minLat = double.infinity;
  double minLng = double.infinity;
  double maxLat = double.negativeInfinity;
  double maxLng = double.negativeInfinity;

  for (final location in locations) {
    minLat = min(minLat, location.latLng.latitude);
    minLng = min(minLng, location.latLng.longitude);
    maxLat = max(maxLat, location.latLng.latitude);
    maxLng = max(maxLng, location.latLng.longitude);
  }

  return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
}

double fitBoundsFromTrackData(LatLngBounds bounds, Size containerSize) {
  double log2(double x) {
    return log(x) / log(2);
  }

  double width = bounds.northEast.longitude - bounds.southWest.longitude;
  double height = bounds.northEast.latitude - bounds.southWest.latitude;

  double boundsAspectRatio = width / height;

  double containerAspectRatio = containerSize.width / containerSize.height;

  double scale = containerAspectRatio > boundsAspectRatio ? containerSize.height / height : containerSize.width / width;

  double zoom = log2(scale) - 0.100;

  if (zoom < 0) {
    zoom = 0;
  }

  return zoom;
}

double calculateTrackDistance(List<LatLng> points) {
  double distance = 0;

  for (int i = 0; i < points.length - 1; i++) {
    final point1 = points[i];
    final point2 = points[i + 1];

    const earthRadius = 6371;

    final dLat = _toRadians(point2.latitude - point1.latitude);
    final dLon = _toRadians(point2.longitude - point1.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_toRadians(point1.latitude)) * cos(_toRadians(point2.latitude)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    distance += earthRadius * c;
  }

// retorna distance redondeado a 2 decimales
  return (distance * 100).round() / 100;
}

double _toRadians(double degrees) {
  return degrees * (pi / 180);
}

Future<bool> colorPickerDialog(BuildContext context, Color dialogPickerColor, WidgetRef ref, {Function? onColorChanged}) async {
  return ColorPicker(
    color: dialogPickerColor,
    onColorChanged: (Color color) {
      dialogPickerColor = color;
      ref.read(colorProvider.notifier).update((state) => color);
      if (onColorChanged != null) onColorChanged(color);
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
