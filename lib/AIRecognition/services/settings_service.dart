import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualguide/AIRecognition/models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        return AppSettings.fromJson(jsonDecode(settingsJson));
      }
      return AppSettings(); // Configuración por defecto
    } catch (e) {
      print('Error loading settings: $e');
      return AppSettings();
    }
  }

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }

  // Método para aplicar configuración de voz por comando
  Future<void> applyVoiceCommand(
      String command, AppSettings currentSettings) async {
    // TODO: Implementar lógica de comandos de voz
    // Ejemplos:
    // "aumentar velocidad de voz" -> incrementar speechRate
    // "cambiar tono a serio" -> cambiar voiceTone a 'serious'
    // "sensibilidad alta" -> cambiar sensitivityLevel a 'high'

    AppSettings updatedSettings = currentSettings;

    if (command.toLowerCase().contains('velocidad') ||
        command.toLowerCase().contains('rápido')) {
      // Ajustar velocidad
    } else if (command.toLowerCase().contains('sensibilidad')) {
      // Ajustar sensibilidad
    }

    await saveSettings(updatedSettings);
  }
}
