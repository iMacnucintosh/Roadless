import 'package:flutter/material.dart';

class PublicTracksMarker extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 5);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, size.height - 5);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
