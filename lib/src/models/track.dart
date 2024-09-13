import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Track {
  Track({
    required this.id,
    required this.name,
    required this.trackData,
    required this.points,
    this.color = Colors.blue,
    this.distance = 0.0,
  });

  final String id;
  final String name;
  final String trackData;
  final List<LatLng> points;
  final Color color;
  final double distance;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trackData': trackData,
      'points': points.map((e) => e.toJson()).toList(),
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      trackData: json['trackData'],
      points: [...json['points'].map((e) => LatLng.fromJson(e))],
    );
  }
}
