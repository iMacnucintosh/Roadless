import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MyTileProvider extends TileProvider {
  final String baseUrl;

  MyTileProvider({
    required this.baseUrl,
  });

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final zoom = coordinates.z.toInt();
    final x = coordinates.x.toInt();
    final y = coordinates.y.toInt();

    // Construye la URL de la imagen de acuerdo a tu fuente personalizada.
    final tileUrl = '$baseUrl/$zoom/$x/$y.png?apikey=c1522771387c4170a55beb3ecaaabf61';

    // print('$zoom/$x/$y');
    return tileUrl;
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final tileUrl = getTileUrl(coordinates, options);
    return CachedNetworkImageProvider(
        tileUrl); // O usa una imagen en blanco o un azulejo de respaldo aquí
  }
}
