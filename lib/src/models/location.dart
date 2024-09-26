import 'package:latlong2/latlong.dart';

class Location {
  Location({
    required this.latLng,
    this.elevation = 0,
  });

  LatLng latLng;
  double elevation;

  Map<String, dynamic> toJson() {
    return {
      "latLng": latLng.toJson(),
      "elevation": elevation,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latLng: LatLng.fromJson(json["latLng"]),
      elevation: json["elevation"],
    );
  }
}
