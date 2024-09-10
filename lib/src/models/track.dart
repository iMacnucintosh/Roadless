import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/src/utils.dart';

class Track {
  Track({
    required this.id,
    required this.name,
    required this.trackData,
    required this.points,
  });

  final String id;
  final String name;
  final String trackData;
  final List<LatLng> points;

  LatLngBounds getBounds() {
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

  double fitBounds(LatLngBounds bounds, Size containerSize) {
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

  static LatLngBounds getBoundsFromTrackData(String trackData) {
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

  static double fitBoundsFromTrackData(LatLngBounds bounds, Size containerSize) {
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

  static Future<String?> loadTrackData() async {
    File? trackFile = await pickFile();
    if (trackFile != null) {
      return await trackFile.readAsString();
    }
    return null;
  }

  static List<LatLng> getTrackPoints(String trackData) {
    List<LatLng> points = [];
    List<Wpt> wptPoints = [];
    Gpx track = GpxReader().fromString(trackData);
    if (track.rtes.isNotEmpty) {
      wptPoints = track.rtes.first.rtepts;
    } else if (track.trks.isNotEmpty) {
      wptPoints = track.trks.first.trksegs.first.trkpts;
    }

    for (Wpt point in wptPoints) {
      points.add(LatLng(point.lat!, point.lon!));
    }

    return points;
  }

  static String getTrackName(String trackData) {
    Gpx track = GpxReader().fromString(trackData);

    if (track.metadata == null) {
      return '';
    }
    return track.metadata!.name ?? "";
  }
}
