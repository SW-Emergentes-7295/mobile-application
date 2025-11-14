import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visualguide/shared/infrastructure/services/base_service.dart';

class AuthService extends BaseService {
  /// 🧩 Registro de usuario
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/iam/users');

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
    final url = Uri.parse('${BaseService.baseUrl}/iam/login');

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
