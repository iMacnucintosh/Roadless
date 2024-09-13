import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Waypoint {
  Waypoint({
    required this.name,
    required this.description,
    required this.location,
    this.icon = Icons.location_pin,
  });

  final String name;
  final String description;
  final LatLng location;
  final IconData icon;
}
