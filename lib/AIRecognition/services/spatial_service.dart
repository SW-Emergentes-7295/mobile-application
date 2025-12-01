import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:visualguide/AIRecognition/models/detected_object.dart';
import 'package:visualguide/AIRecognition/models/spatial_data.dart';
import 'package:visualguide/AIRecognition/models/navigation_instruction.dart';
import 'package:visualguide/AIRecognition/models/bounding_box.dart';
import 'dart:math' as Math;
import 'package:flutter/material.dart';

class SpatialService {
  // Streams para sensores
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Datos actuales
  SpatialData? _currentSpatialData;
  String _currentLocation = 'unknown';
  List<DetectedObject> _detectedObjects = [];

  // Configuración de sensibilidad
  double _proximityThreshold = 1.5; // Distancia de alerta en metros

  // Calibración de cámara para estimación de distancia
  final double _focalLength = 800.0; // Focal length en píxeles
  final double _sensorHeight = 4.8; // Altura del sensor en mm (ejemplo iPhone)

  SpatialService();

  // ===================================
  // INICIALIZACIÓN Y SENSORES
  // ===================================

  Future<void> initialize() async {
    await _startSensorListening();
  }

  Future<void> _startSensorListening() async {
    // Escuchar acelerómetro para detectar movimiento
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      _handleAccelerometerData(event);
    });

    // Escuchar giroscopio para detectar rotación
    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      _handleGyroscopeData(event);
    });
  }

  void _handleAccelerometerData(AccelerometerEvent event) {
    // TODO: Procesar datos de acelerómetro
    // Detectar si el usuario está caminando, parado, etc.
    double magnitude = _calculateMagnitude(event.x, event.y, event.z);

    if (magnitude > 15.0) {
      // Usuario en movimiento
      print('Usuario en movimiento: $magnitude');
    }
  }

  void _handleGyroscopeData(GyroscopeEvent event) {
    // TODO: Procesar datos de giroscopio
    // Detectar orientación y rotación del dispositivo
    print('Rotación: x=${event.x}, y=${event.y}, z=${event.z}');
  }

  double _calculateMagnitude(double x, double y, double z) {
    return Math.sqrt(x * x + y * y + z * z);
  }

  // ===================================
  // ESTIMACIÓN DE DISTANCIA
  // ===================================

  /// Estima la distancia basándose en el tamaño del objeto en la imagen
  /// y el tamaño real conocido del objeto
  double estimateDistance({
    required double objectHeightInPixels,
    required double realObjectHeightInMeters,
    required double imageHeightInPixels,
  }) {
    // Fórmula: distancia = (altura_real × focal_length) / altura_en_píxeles
    double distance =
        (realObjectHeightInMeters * _focalLength) / objectHeightInPixels;
    return distance;
  }

  /// Estima distancia usando el bounding box y altura conocida del objeto
  double calculateDistanceFromBoundingBox({
    required BoundingBox box,
    required String objectLabel,
    required double imageHeight,
  }) {
    // Alturas promedio de objetos comunes (en metros)
    Map<String, double> objectHeights = {
      'chair': 0.9,
      'table': 0.75,
      'door': 2.0,
      'person': 1.7,
      'sofa': 0.85,
      'bed': 0.6,
      'shelf': 1.8,
      'counter': 0.9,
      'cabinet': 0.9,
    };

    double realHeight = objectHeights[objectLabel.toLowerCase()] ?? 1.0;
    double pixelHeight = box.height * imageHeight;

    if (pixelHeight > 0) {
      return estimateDistance(
        objectHeightInPixels: pixelHeight,
        realObjectHeightInMeters: realHeight,
        imageHeightInPixels: imageHeight,
      );
    }

    return 5.0; // Distancia por defecto si no se puede calcular
  }

  /// Determina la posición del objeto relativa al centro de la cámara
  String determineObjectPosition(BoundingBox box) {
    Offset center = box.getCenter();

    // Dividir la imagen en zonas
    if (center.dx < 0.33) {
      return 'left';
    } else if (center.dx > 0.66) {
      return 'right';
    } else {
      return 'center';
    }
  }

  // ===================================
  // PROCESAMIENTO DE DETECCIONES
  // ===================================

  /// Procesa objetos detectados por el modelo de IA
  Future<SpatialData> processDetections({
    required List<Map<String, dynamic>> detections,
    required double imageHeight,
    required double imageWidth,
  }) async {
    List<DetectedObject> objects = [];

    for (var detection in detections) {
      BoundingBox box = BoundingBox(
        x: detection['bbox'][0] / imageWidth,
        y: detection['bbox'][1] / imageHeight,
        width: detection['bbox'][2] / imageWidth,
        height: detection['bbox'][3] / imageHeight,
      );

      double distance = calculateDistanceFromBoundingBox(
        box: box,
        objectLabel: detection['label'],
        imageHeight: imageHeight,
      );

      String position = determineObjectPosition(box);

      DetectedObject obj = DetectedObject(
        id: '${detection['label']}_${DateTime.now().millisecondsSinceEpoch}',
        label: detection['label'],
        confidence: detection['confidence'],
        boundingBox: box,
        distance: distance,
        position: position,
        timestamp: DateTime.now(),
      );

      objects.add(obj);
    }

    // Ordenar por distancia (más cercanos primero)
    objects.sort((a, b) => a.distance.compareTo(b.distance));
    _detectedObjects = objects;

    // Crear datos espaciales
    _currentSpatialData = SpatialData(
      currentLocation: _currentLocation,
      nearbyObjects: objects,
      roomDistances: await _estimateRoomDistances(objects),
      deviceOrientation: Orientation.portrait,
      lastUpdate: DateTime.now(),
    );

    return _currentSpatialData!;
  }

  /// Estima distancias a diferentes habitaciones basándose en objetos detectados
  Future<Map<String, double>> _estimateRoomDistances(
      List<DetectedObject> objects) async {
    Map<String, double> distances = {};

    // TODO: Implementar lógica basada en objetos característicos de cada habitación
    // Por ejemplo, si se detecta una estufa, probablemente esté cerca de la cocina

    Map<String, List<String>> roomObjects = {
      'kitchen': ['stove', 'refrigerator', 'sink', 'counter'],
      'bedroom': ['bed', 'nightstand', 'closet'],
      'bathroom': ['toilet', 'sink', 'shower'],
      'living_room': ['sofa', 'tv', 'coffee_table'],
    };

    for (var room in roomObjects.keys) {
      List<String> roomItems = roomObjects[room]!;
      List<DetectedObject> matchingObjects = objects
          .where((obj) => roomItems.contains(obj.label.toLowerCase()))
          .toList();

      if (matchingObjects.isNotEmpty) {
        // Usar el objeto más cercano como referencia
        distances[room] = matchingObjects.first.distance;
      } else {
        distances[room] = 10.0; // Distancia desconocida
      }
    }

    return distances;
  }

  // ===================================
  // GENERACIÓN DE INSTRUCCIONES
  // ===================================

  /// Genera instrucciones de navegación basadas en el objetivo del usuario
  NavigationInstruction generateNavigationInstruction({
    required String targetRoom,
    required SpatialData spatialData,
  }) {
    List<DetectedObject> criticalObstacles = spatialData.getCriticalObjects();
    List<DetectedObject> pathObstacles =
        spatialData.getObjectsInDirection('center');

    String action = 'walk_forward';
    String description = '';
    double distance = 0.0;
    String priority = 'medium';

    // Verificar obstáculos inmediatos
    if (criticalObstacles.isNotEmpty) {
      DetectedObject nearest = criticalObstacles.first;

      if (nearest.distance < 0.5) {
        action = 'stop';
        description =
            'Detente. Hay un ${nearest.label} muy cerca a ${nearest.distance.toStringAsFixed(1)} metros';
        priority = 'high';
      } else if (nearest.position == 'center') {
        action = 'turn_left';
        description =
            'Gira a la izquierda para evitar ${nearest.label} que está a ${nearest.distance.toStringAsFixed(1)} metros';
        priority = 'high';
      }
    } else {
      // Camino despejado, dar instrucciones hacia el objetivo
      double? roomDistance = spatialData.roomDistances[targetRoom];

      if (roomDistance != null && roomDistance < 5.0) {
        action = 'walk_forward';
        description =
            'Camina hacia adelante. La $targetRoom está aproximadamente a ${roomDistance.toStringAsFixed(1)} metros';
        distance = roomDistance;
        priority = 'medium';
      } else {
        action = 'walk_forward';
        description = 'Camina hacia adelante. El camino está despejado';
        priority = 'low';
      }
    }

    return NavigationInstruction(
      action: action,
      description: description,
      distance: distance,
      targetRoom: targetRoom,
      obstacles: criticalObstacles,
      priority: priority,
      timestamp: DateTime.now(),
    );
  }

  /// Genera alertas de proximidad para objetos cercanos
  List<String> generateProximityAlerts(SpatialData spatialData) {
    List<String> alerts = [];

    for (var obj in spatialData.nearbyObjects) {
      if (obj.distance < _proximityThreshold) {
        String alertLevel = obj.getAlertLevel();

        if (alertLevel == 'critical') {
          alerts.add('¡CUIDADO! ${obj.label} muy cerca a tu ${obj.position}');
        } else if (alertLevel == 'warning') {
          alerts.add(
              'Precaución: ${obj.label} a ${obj.distance.toStringAsFixed(1)}m a tu ${obj.position}');
        }
      }
    }

    return alerts;
  }
  // ===================================
  // TRACKING DE UBICACIÓN
  // ===================================

  /// Actualiza la ubicación actual basándose en los objetos detectados
  void updateCurrentLocation(List<DetectedObject> objects) {
    Map<String, int> roomScores = {
      'kitchen': 0,
      'bedroom': 0,
      'bathroom': 0,
      'living_room': 0,
      'hallway': 0,
    };

    Map<String, List<String>> roomIndicators = {
      'kitchen': ['stove', 'refrigerator', 'sink', 'microwave', 'counter'],
      'bedroom': ['bed', 'nightstand', 'dresser', 'closet'],
      'bathroom': ['toilet', 'sink', 'shower', 'bathtub', 'mirror'],
      'living_room': ['sofa', 'tv', 'coffee_table', 'armchair'],
      'hallway': ['door', 'picture', 'corridor'],
    };

    // Puntuar cada habitación según objetos detectados
    for (var obj in objects) {
      for (var room in roomIndicators.keys) {
        if (roomIndicators[room]!.contains(obj.label.toLowerCase())) {
          roomScores[room] = roomScores[room]! + 1;
        }
      }
    }

    // Determinar la habitación con mayor puntuación
    String mostLikelyRoom = 'unknown';
    int maxScore = 0;

    roomScores.forEach((room, score) {
      if (score > maxScore) {
        maxScore = score;
        mostLikelyRoom = room;
      }
    });

    if (maxScore > 0) {
      _currentLocation = mostLikelyRoom;
    }
  }

  // ===================================
  // GETTERS Y CONFIGURACIÓN
  // ===================================

  SpatialData? get currentSpatialData => _currentSpatialData;
  String get currentLocation => _currentLocation;
  List<DetectedObject> get detectedObjects => _detectedObjects;

  void setProximityThreshold(double threshold) {
    _proximityThreshold = threshold;
  }

  void setCurrentLocation(String location) {
    _currentLocation = location;
  }

  // ===================================
  // LIMPIEZA
  // ===================================

  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
  }
}
