import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Waypoint {
  Waypoint({
    required this.name,
    required this.description,
    required this.location,
    this.elevation = 0,
    this.icon = Icons.location_on,
  });

  String name;
  String description;
  LatLng location;
  double elevation;
  IconData icon;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "location": location.toJson(),
      "elevation": elevation,
    };
  }

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      name: json["name"],
      description: json["description"],
      location: LatLng.fromJson(json["location"]),
      elevation: json["elevation"],
    );
  }
}
