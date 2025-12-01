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

  /// Start listening with interim and final result callbacks
  Future<void> startListening(
    Function(String) onInterimResult, {
    Function(String)? onFinalResult,
  }) async {
    _isListening = true;
    await _speechToText.listen(
      onResult: (result) {
        final text = result.recognizedWords;
        if (result.finalResult) {
          // Final recognized text
          if (onFinalResult != null && text.isNotEmpty) {
            onFinalResult(text);
          }
        } else {
          // Interim partial text
          onInterimResult(text);
        }
      },
      localeId: 'es_ES',
      listenMode: ListenMode.confirmation, // ensures finalResult is called
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    await stopListening();
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setVoiceTone(String tone) async {
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
