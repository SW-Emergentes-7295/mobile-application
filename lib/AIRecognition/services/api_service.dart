import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://your-api-url.com/api';

  Future<String> sendVoiceCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/voice-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? '';
      }
      return 'Error en la respuesta';
    } catch (e) {
      return 'Error de conexión';
    }
  }

  Future<Map<String, dynamic>> detectObjects(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/detect-objects'),
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
}
