import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadless/src/constants/enums.dart';
import 'package:roadless/src/models/waypoint.dart';

class Track {
  Track({
    required this.id,
    required this.name,
    required this.points,
    this.waypoints = const [],
    this.color = Colors.blue,
    this.distance = 0.0,
    this.activityType,
  });

  String id;
  String name;
  List<LatLng> points;
  List<Waypoint> waypoints;
  Color color;
  double distance;
  ActivityType? activityType;

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
      'points': points.map((point) => point.toJson()).toList(),
      'waypoints': waypoints.map((waypoint) => waypoint.toJson()).toList(),
      'color': color.value,
      'distance': distance,
      'activityType': activityType?.name,
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      points: [...json['points'].map((e) => LatLng.fromJson(e))],
      waypoints: [...json['waypoints'].map((e) => Waypoint.fromJson(e))],
      color: Color(json['color']),
      distance: json['distance'],
      activityType: json.containsKey('activityType') ? ActivityType.fromName(json["activityType"]) : null,
    );
  }

  String toGpx() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="Roadless" xmlns="http://www.topografix.com/GPX/1/1">');
    buffer.writeln('<metadata>');
    buffer.writeln('<name>$name</name>');
    buffer.writeln('<desc>$name</desc>');
    buffer.writeln('</metadata>');

    buffer.writeln('<trk>');
    buffer.writeln('<name>$name</name>');

    buffer.writeln('<trkseg>');

    for (final point in points) {
      buffer.writeln('<trkpt lat="${point.latitude}" lon="${point.longitude}">');
      buffer.writeln('<ele>0</ele>'); // TODO: Ver si es posible ajustar la elevación
      buffer.writeln('</trkpt>');
    }

    buffer.writeln('</trkseg>');
    buffer.writeln('</trk>');

    for (final waypoint in waypoints) {
      buffer.writeln('<wpt lat="${waypoint.location.latitude}" lon="${waypoint.location.longitude}">');
      buffer.writeln('<name>${waypoint.name}</name>');
      buffer.writeln('<desc>${waypoint.description}</desc>');
      buffer.writeln('</wpt>');
    }

    buffer.writeln('</gpx>');

    return buffer.toString();
  }
}
