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

List<LatLng> getTrackPoints(String trackData) {
  List<LatLng> trackPoints = [];
  List<Wpt> points = [];
  Gpx track = GpxReader().fromString(trackData);
  if (track.rtes.isNotEmpty) {
    points = track.rtes.first.rtepts;
  } else if (track.trks.isNotEmpty) {
    points = track.trks.first.trksegs.first.trkpts;
  }

  for (Wpt point in points) {
    trackPoints.add(LatLng(point.lat!, point.lon!));
  }

  return trackPoints;
}

List<Waypoint> getTrackwaypoints(String trackData) {
  List<Waypoint> waypoints = [];
  Gpx track = GpxReader().fromString(trackData);

  for (Wpt point in track.wpts) {
    waypoints.add(Waypoint(name: point.name ?? "", description: point.desc ?? "", location: LatLng(point.lat!, point.lon!)));
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
  List<LatLng> points = getTrackPoints(trackData);
  double minLat = double.infinity;
  double minLng = double.infinity;
  double maxLat = double.negativeInfinity;
  double maxLng = double.negativeInfinity;

  for (final point in points) {
    minLat = min(minLat, point.latitude);
    minLng = min(minLng, point.longitude);
    maxLat = max(maxLat, point.latitude);
    maxLng = max(maxLng, point.longitude);
  }

  return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
}

double fitBoundsFromTrackData(LatLngBounds bounds, Size containerSize) {
  double log2(double x) {
    return log(x) / log(2);
  }

  double minDimension(Size size) {
    return size.width < size.height ? size.width : size.height;
  }

  double width = bounds.northEast.longitude - bounds.southWest.longitude;
  double height = bounds.northEast.latitude - bounds.southWest.latitude;

  Size size = Size(width, height);
  final aspectRatio = containerSize.width / containerSize.height;
  final offset = size.height * (containerSize.aspectRatio - aspectRatio) / 2;

  double zoom = log2(minDimension(containerSize) / (size.width + 2 * offset)) + 0.001;

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
