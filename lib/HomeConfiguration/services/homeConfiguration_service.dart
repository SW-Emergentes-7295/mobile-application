import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visualguide/shared/infrastructure/services/base_service.dart';

class HomeconfigurationService extends BaseService{
  Future<Map<String, dynamic>> sendRagConfigurationCommand(String userId, String imageDirectory) async{
    try{
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseService.baseUrl}/setup-rag'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', "${imageDirectory}/living_room/living_room_1.jpg"));
      request.files.add(await http.MultipartFile.fromPath('image', "${imageDirectory}/living_room/living_room_2.jpg"));
      request.files.add(await http.MultipartFile.fromPath('image', "${imageDirectory}/bedroom/bedroom_1.jpg"));
      request.files.add(await http.MultipartFile.fromPath('image', "${imageDirectory}/bedroom/bedroom_2.jpg"));
      request.files.add(await http.MultipartFile.fromPath('image', "${imageDirectory}/kitchen/kitchen.jpg"));
      request.files.add(await http.MultipartFile.fromPath('image', "${imageDirectory}/dining_room/dining_room.jpg"));
      request.files.add(await http.MultipartFile.fromPath('image', "${imageDirectory}/bathroom/bathroom.jpg"));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      }

      return {'error': 'Error en la configuración'};
    } catch (e) {
      return {'error': 'Error de conexión'};
    }
  }
}