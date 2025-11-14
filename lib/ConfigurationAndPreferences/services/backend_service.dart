import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visualguide/shared/infrastructure/services/base_service.dart';

class BackendService extends BaseService {
  // POST: vincular usuario y cuidador
  static Future<Map<String, dynamic>> linkUser(
      String userId, String caregiverId) async {
    final url =
        Uri.parse("${BaseService.baseUrl}/configuration-preferences/link");
    final response = await http.post(url, body: {
      "user_id": userId,
      "caregiver_id": caregiverId,
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al vincular: ${response.body}");
    }
  }

  // GET: obtener vínculos
  static Future<List<dynamic>> getLinks() async {
    final url =
        Uri.parse("${BaseService.baseUrl}/configuration-preferences/links");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al obtener vínculos");
    }
  }
}
