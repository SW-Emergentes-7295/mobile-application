import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class BaseService {
  // Can be overridden at runtime or via --dart-define
  static String url = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.80:8000/api/v1',
  );

  // Optional helpers
  static String get baseUrl => url;
  static void setBaseUrl(String newUrl) => url = newUrl;

  final storage = const FlutterSecureStorage();
}
