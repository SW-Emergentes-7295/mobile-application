import 'package:visualguide/AIRecognition/models/detected_object.dart';

class NavigationInstruction {
  final String action; // "walk_forward", "turn_left", "turn_right", "stop"
  final String description; // Descripción en lenguaje natural
  final double distance; // Distancia a recorrer (si aplica)
  final String targetRoom; // Habitación objetivo
  final List<DetectedObject> obstacles; // Obstáculos a evitar
  final String priority; // "high", "medium", "low"
  final DateTime timestamp;

  NavigationInstruction({
    required this.action,
    required this.description,
    this.distance = 0.0,
    required this.targetRoom,
    required this.obstacles,
    this.priority = 'medium',
    required this.timestamp,
  });

  factory NavigationInstruction.fromJson(Map<String, dynamic> json) {
    return NavigationInstruction(
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      distance: (json['distance'] ?? 0.0).toDouble(),
      targetRoom: json['targetRoom'] ?? '',
      obstacles: (json['obstacles'] as List?)
              ?.map((obj) => DetectedObject.fromJson(obj))
              .toList() ??
          [],
      priority: json['priority'] ?? 'medium',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'description': description,
      'distance': distance,
      'targetRoom': targetRoom,
      'obstacles': obstacles.map((obj) => obj.toJson()).toList(),
      'priority': priority,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Obtener instrucción con alertas de obstáculos
  String getFullInstruction() {
    String baseInstruction = description;

    if (obstacles.isNotEmpty) {
      List<String> obstacleWarnings = obstacles
          .where((obj) => obj.distance < 1.5)
          .map((obj) =>
              'Cuidado: ${obj.label} a ${obj.distance.toStringAsFixed(1)} metros')
          .toList();

      if (obstacleWarnings.isNotEmpty) {
        baseInstruction += '. ${obstacleWarnings.join('. ')}';
      }
    }

    return baseInstruction;
  }
}
