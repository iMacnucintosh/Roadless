import 'dart:typed_data';

class Track {
  Track({
    required this.id,
    required this.name,
    this.image,
  });

  String id;
  String name;
  final Uint8List? image;
}
