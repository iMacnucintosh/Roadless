import 'package:roadless/src/models/location.dart';

class Waypoint {
  Waypoint({
    required this.name,
    required this.description,
    required this.location,
  });

  String name;
  String description;
  Location location;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "location": location.toJson(),
    };
  }

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      name: json["name"],
      description: json["description"],
      location: Location.fromJson(json["location"]),
    );
  }
}
