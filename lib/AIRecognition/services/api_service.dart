import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visualguide/shared/infrastructure/services/base_service.dart';
import 'package:visualguide/AIRecognition/models/detected_object.dart';
import 'package:visualguide/AIRecognition/models/navigation_instruction.dart';

class ApiService extends BaseService {
  Future<String> sendVoiceCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/ai-recognition/voice-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? '';
      }

      print('API Error: ${response.statusCode} - ${response.body}');
      return 'Error en la respuesta';
    } catch (e) {
      print('Connection Error: $e');
      return 'Error de conexión';
    }
  }

  Future<Map<String, dynamic>> getFamiliarLinked(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseService.baseUrl}/users/$userId/familiar-linked'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      print('API Error: ${response.statusCode} - ${response.body}');
      return {'error': 'Error en la respuesta'};
    } catch (e) {
      print('Connection Error: $e');
      return {'error': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> detectObjects(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseService.baseUrl}/detect-objects'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      }
      return {'error': 'Error en detección'};
    } catch (e) {
      return {'error': 'Error de conexión'};
    }
  }

  Future<List<DetectedObject>> detectObjectsWithSpatialData({
    required String imagePath,
    required double imageWidth,
    required double imageHeight,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseService.baseUrl}/ai-recognition/detect-objects'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.fields['image_width'] = imageWidth.toString();
      request.fields['image_height'] = imageHeight.toString();

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);

        List<DetectedObject> objects = [];
        for (var detection in data['detections']) {
          objects.add(DetectedObject.fromJson(detection));
        }

        return objects;
      }
      return [];
    } catch (e) {
      print('Error en detección: $e');
      return [];
    }
  }

  Future<NavigationInstruction?> getNavigationInstructions({
    required String currentLocation,
    required String targetRoom,
    required List<DetectedObject> nearbyObjects,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${BaseService.baseUrl}/ai-recognition/navigation/instructions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_location': currentLocation,
          'target_room': targetRoom,
          'nearby_objects': nearbyObjects.map((obj) => obj.toJson()).toList(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NavigationInstruction.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo instrucciones: $e');
      return null;
    }
  }
}
