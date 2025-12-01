import 'package:visualguide/AIRecognition/models/detected_object.dart';
import 'package:flutter/material.dart';

class SpatialData {
  final String currentLocation; // "living_room", "kitchen", "bedroom"
  final List<DetectedObject> nearbyObjects; // Objetos cercanos detectados
  final Map<String, double>
      roomDistances; // Distancias a diferentes habitaciones
  final double userHeight; // Altura del usuario en metros
  final Orientation deviceOrientation; // Orientación del dispositivo
  final DateTime lastUpdate;

  SpatialData({
    required this.currentLocation,
    required this.nearbyObjects,
    required this.roomDistances,
    this.userHeight = 1.65, // Altura promedio
    required this.deviceOrientation,
    required this.lastUpdate,
  });

  factory SpatialData.fromJson(Map<String, dynamic> json) {
    return SpatialData(
      currentLocation: json['currentLocation'] ?? 'unknown',
      nearbyObjects: (json['nearbyObjects'] as List?)
              ?.map((obj) => DetectedObject.fromJson(obj))
              .toList() ??
          [],
      roomDistances: Map<String, double>.from(json['roomDistances'] ?? {}),
      userHeight: (json['userHeight'] ?? 1.65).toDouble(),
      deviceOrientation: Orientation.values.firstWhere(
        (e) => e.toString() == json['deviceOrientation'],
        orElse: () => Orientation.portrait,
      ),
      lastUpdate: DateTime.parse(
          json['lastUpdate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLocation': currentLocation,
      'nearbyObjects': nearbyObjects.map((obj) => obj.toJson()).toList(),
      'roomDistances': roomDistances,
      'userHeight': userHeight,
      'deviceOrientation': deviceOrientation.toString(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  // Obtener objetos críticos (muy cercanos)
  List<DetectedObject> getCriticalObjects() {
    return nearbyObjects.where((obj) => obj.distance < 1.0).toList();
  }

  // Obtener objetos en una dirección específica
  List<DetectedObject> getObjectsInDirection(String direction) {
    return nearbyObjects.where((obj) => obj.position == direction).toList();
  }

  // Generar descripción del entorno
  String getEnvironmentDescription() {
    if (nearbyObjects.isEmpty) {
      return 'No se detectan objetos cercanos. El camino está despejado.';
    }

    List<String> descriptions = nearbyObjects
        .where((obj) => obj.distance < 3.0)
        .map((obj) => obj.getDescription())
        .toList();

    return descriptions.join(', ');
  }
}
