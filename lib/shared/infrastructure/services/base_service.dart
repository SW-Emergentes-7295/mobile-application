import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class BaseService {
  final baseUrl = 'http://localhost:8000/api/v1';

  final storage = const FlutterSecureStorage();
}
