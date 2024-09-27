import 'package:roadless/src/models/location.dart';

class Waypoint {
  Waypoint({
    required this.name,
    required this.location,
  });

  String name;
  Location location;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "location": location.toJson(),
    };
  }

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      name: json["name"],
      location: Location.fromJson(json["location"]),
    );
  }
}
