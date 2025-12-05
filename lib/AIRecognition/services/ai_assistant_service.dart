import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visualguide/shared/infrastructure/services/base_service.dart';
import 'package:visualguide/AIRecognition/models/detected_object.dart';
import 'package:visualguide/AIRecognition/models/navigation_instruction.dart';

class AIAssistantService extends BaseService {
  // Historial de contexto para mantener coherencia
  final List<Map<String, dynamic>> _conversationHistory = [];
  String? _currentTargetRoom;
  String? _lastSpokenObject;
  DateTime? _lastObjectAnnouncementTime;

  // Los prompts ahora se construyen en el backend con Gemini

  /// Formatea nombres de ubicaciones
  String _formatLocation(String location) {
    Map<String, String> translations = {
      'kitchen': 'Cocina',
      'bedroom': 'Dormitorio',
      'bathroom': 'Baño',
      'living_room': 'Sala',
      'hallway': 'Pasillo',
      'unknown': 'Ubicación desconocida',
    };
    return translations[location] ?? location;
  }

  /// Envía comando al backend con contexto completo
  Future<Map<String, dynamic>> processVoiceCommandWithContext({
    required String userCommand,
    required List<DetectedObject> detectedObjects,
    required String currentLocation,
    String? targetRoom,
    String sessionId = 'default',
  }) async {
    try {
      // Enviar al backend (el backend construye el prompt internamente con Gemini)
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/ai-recognition/assistant/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_command': userCommand,
          'spatial_context': {
            'detected_objects':
                detectedObjects.map((obj) => obj.toJson()).toList(),
            'current_location': currentLocation,
            'target_room': targetRoom,
          },
          'conversation_history': _conversationHistory.take(10).toList(),
          'session_id': sessionId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Actualizar historial
        _conversationHistory.add({
          'speaker': 'User',
          'text': userCommand,
          'timestamp': DateTime.now().toIso8601String(),
        });

        _conversationHistory.add({
          'speaker': 'Assistant',
          'text': data['response_text'] ?? '',
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Actualizar objetivo si cambió
        if (data['target_room'] != null) {
          _currentTargetRoom = data['target_room'];
        }

        return data;
      }

      return {
        'response_text': 'Lo siento, hubo un error procesando tu comando.',
        'action': 'inform',
        'priority': 'low',
        'should_speak_immediately': true,
      };
    } catch (e) {
      print('Error en processVoiceCommandWithContext: $e');
      return {
        'response_text': 'Error de conexión con el asistente.',
        'action': 'inform',
        'priority': 'low',
        'should_speak_immediately': true,
      };
    }
  }

  /// Detecta objetos nuevos y genera alertas proactivas
  Future<Map<String, dynamic>?> generateProactiveAlert({
    required List<DetectedObject> newObjects,
    required List<DetectedObject> previousObjects,
    required String currentLocation,
  }) async {
    // Identificar objetos nuevos o que se acercaron significativamente
    List<DetectedObject> alertObjects = [];

    for (var newObj in newObjects) {
      // Buscar si el objeto ya existía
      var previousObj = previousObjects.firstWhere(
        (prev) =>
            prev.label == newObj.label && prev.position == newObj.position,
        orElse: () => newObj,
      );

      // Objeto nuevo peligroso
      if (previousObj.id == newObj.id && newObj.distance < 1.5) {
        alertObjects.add(newObj);
      }
      // Objeto que se acercó más de 0.5m
      else if (previousObj.id != newObj.id &&
          (previousObj.distance - newObj.distance) > 0.5) {
        alertObjects.add(newObj);
      }
    }

    if (alertObjects.isEmpty) return null;

    // Evitar repetir alertas del mismo objeto muy seguido
    final now = DateTime.now();
    if (_lastObjectAnnouncementTime != null &&
        now.difference(_lastObjectAnnouncementTime!).inSeconds < 5 &&
        _lastSpokenObject == alertObjects.first.label) {
      return null;
    }

    // Generar alerta proactiva
    try {
      final mostCritical =
          alertObjects.reduce((a, b) => a.distance < b.distance ? a : b);

      final alertPrompt = '''
Genera una alerta corta y directa para el siguiente objeto detectado:

Objeto: ${mostCritical.label}
Distancia: ${mostCritical.distance.toStringAsFixed(1)}m
Posición: ${mostCritical.position}
Nivel de alerta: ${mostCritical.getAlertLevel()}

La alerta debe ser:
- Muy breve (máximo 10 palabras)
- Directa y clara
- Urgente si la distancia es < 1m

Ejemplo: "Atención: silla a 0.8 metros al frente"
''';

      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/ai-recognition/assistant/alert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'object': mostCritical.toJson(),
          'priority': mostCritical.getAlertLevel(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _lastSpokenObject = mostCritical.label;
        _lastObjectAnnouncementTime = now;

        return {
          'response_text': data['alert_text'] ?? mostCritical.getDescription(),
          'action': 'alert',
          'priority':
              mostCritical.getAlertLevel() == 'critical' ? 'high' : 'medium',
          'should_speak_immediately': true,
          'object': mostCritical.toJson(),
        };
      }
    } catch (e) {
      print('Error generando alerta proactiva: $e');
    }

    return null;
  }

  /// Limpia el historial de conversación
  void clearHistory() {
    _conversationHistory.clear();
    _currentTargetRoom = null;
  }

  /// Actualiza el destino objetivo
  void setTargetRoom(String? room) {
    _currentTargetRoom = room;
  }

  String? get currentTargetRoom => _currentTargetRoom;
}
