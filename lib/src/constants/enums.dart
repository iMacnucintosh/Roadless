import 'package:flutter/material.dart';

enum ActivityType {
  trailRoad(
    name: "trail_road",
    label: "Trail asfáltica",
    icon: Icons.sports_motorsports_outlined,
  ),
  trailMix(
    name: "trail_mix",
    label: "Trail Mixta",
    icon: Icons.motorcycle_outlined,
  ),
  trail(
    name: "trail",
    label: "Trail",
    icon: Icons.two_wheeler_outlined,
  ),
  bike(
    name: "bike",
    label: "Bicicleta",
    icon: Icons.directions_bike_outlined,
  ),
  mountainBike(
    name: "mountain_bike",
    label: "Bici de montaña",
    icon: Icons.pedal_bike,
  ),
  hiking(
    name: "hiking",
    label: "Senderismo",
    icon: Icons.hiking_outlined,
  ),
  car(
    name: "car",
    label: "Coche",
    icon: Icons.directions_car_outlined,
  );

  const ActivityType({
    required this.name,
    required this.label,
    required this.icon,
  });

  final String name;
  final String label;
  final IconData icon;

  static ActivityType? fromName(String name) {
    return ActivityType.values.firstWhere((type) => type.name == name);
  }
}
