import 'dart:ui';

import 'package:latlong2/latlong.dart';

class Track {
  String name;
  Color color;
  List<LatLng> points;

  Track({
    required this.name,
    required this.color,
    required this.points,
  });

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        name: json["name"],
        color: Color(json["color"]),
        points: List<LatLng>.from(
          json["points"]!.map(
            (x) => LatLng.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "color": color.value,
        "points": List<dynamic>.from(
          points.map(
            (x) => x.toJson(),
          ),
        ),
      };
}
