import 'package:visualguide/AIRecognition/models/bounding_box.dart';

class DetectedObject {
  final String id;
  final String label; // Nombre del objeto: "chair", "door", "table"
  final double confidence; // Confianza de detección (0.0 - 1.0)
  final BoundingBox boundingBox; // Posición en la imagen
  final double distance; // Distancia estimada en metros
  final String position; // "front", "left", "right", "center"
  final DateTime timestamp;

  DetectedObject({
    required this.id,
    required this.label,
    required this.confidence,
    required this.boundingBox,
    required this.distance,
    required this.position,
    required this.timestamp,
  });

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      boundingBox: BoundingBox.fromJson(json['boundingBox'] ?? {}),
      distance: (json['distance'] ?? 0.0).toDouble(),
      position: json['position'] ?? 'center',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'confidence': confidence,
      'boundingBox': boundingBox.toJson(),
      'distance': distance,
      'position': position,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Método para obtener descripción en lenguaje natural
  String getDescription() {
    String distanceText = distance < 1.0
        ? 'muy cerca'
        : distance < 2.0
            ? 'cerca'
            : distance < 3.5
                ? 'a distancia media'
                : 'lejos';

    return '$label $distanceText, a ${distance.toStringAsFixed(1)} metros';
  }

  // Método para determinar nivel de alerta
  String getAlertLevel() {
    if (distance < 0.5) return 'critical'; // Peligro inmediato
    if (distance < 1.5) return 'warning'; // Precaución
    if (distance < 3.0) return 'info'; // Información
    return 'none'; // Sin alerta
  }
}
