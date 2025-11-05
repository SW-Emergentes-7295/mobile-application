import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<void> initialize() async {
    await _speechToText.initialize();
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isListening) {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: 'es_ES',
      );
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    await stopListening();
  }

  // Método para cambiar la velocidad de habla dinámicamente
  Future<void> setSpeechRate(double rate) async {
    // rate debe estar entre 0.0 y 1.0
    await _flutterTts.setSpeechRate(rate);
  }

  // Método para cambiar el tono de voz
  Future<void> setVoiceTone(String tone) async {
    // TODO: Implementar lógica para diferentes tonos
    switch (tone) {
      case 'serious':
        await _flutterTts.setPitch(0.8);
        await _flutterTts.setSpeechRate(0.4);
        break;
      case 'clear':
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
        break;
      case 'fast':
        await _flutterTts.setPitch(1.1);
        await _flutterTts.setSpeechRate(0.7);
        break;
      default:
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
    }
  }
}
