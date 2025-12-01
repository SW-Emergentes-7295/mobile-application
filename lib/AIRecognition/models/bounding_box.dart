import 'package:flutter/material.dart';

class BoundingBox {
  final double x; // Posición X (normalizada 0-1)
  final double y; // Posición Y (normalizada 0-1)
  final double width; // Ancho (normalizado 0-1)
  final double height; // Alto (normalizado 0-1)

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
      width: (json['width'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  // Calcula el centro del objeto
  Offset getCenter() {
    return Offset(x + width / 2, y + height / 2);
  }
}
