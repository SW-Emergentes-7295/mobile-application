import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 🔧 URL base de tu API Flask
  static const String baseUrl = "http://127.0.0.1:8000/api/v1/iam";
  // ⚠️ Cambia 127.0.0.1 por la IP local si pruebas en un emulador o dispositivo físico:
  // Android emulator → "http://10.0.2.2:8000/api/v1/iam"
  // Dispositivo físico → tu IP local, ej: "http://192.168.1.5:8000/api/v1/iam"

  /// 🧩 Registro de usuario
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/users');

    final body = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar usuario: ${response.body}');
    }
  }

  /// 🔐 Login de usuario
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      // Devuelve el token y la info del usuario
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Credenciales inválidas');
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }
}
