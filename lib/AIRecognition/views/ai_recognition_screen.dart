import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:visualguide/shared/widgets/top_nav_bar.dart';
import 'package:visualguide/shared/widgets/bottom_nav_bar.dart';
import 'package:visualguide/AIRecognition/widgets/transcript_panel.dart';
import 'package:visualguide/AIRecognition/models/transcript_message.dart';
import 'package:visualguide/AIRecognition/services/camera_service.dart';
import 'package:visualguide/AIRecognition/services/speech_service.dart';
import 'package:visualguide/AIRecognition/services/api_service.dart';

class AIRecognitionScreen extends StatefulWidget {
  const AIRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<AIRecognitionScreen> createState() => _AIRecognitionScreenState();
}

class _AIRecognitionScreenState extends State<AIRecognitionScreen> {
  final CameraService _cameraService = CameraService();
  final SpeechService _speechService = SpeechService();
  final ApiService _apiService = ApiService();

  int _currentNavIndex = 1;
  bool _isListening = false;
  List<TranscriptMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    // Mensaje de ejemplo inicial
    _messages = [
      TranscriptMessage(
        speaker: 'User',
        text: 'I want to go to the kitchen and look for a spoon to eat.',
        timestamp: DateTime.now(),
      ),
      TranscriptMessage(
        speaker: 'Assistant',
        text:
            'Perfect Arian! Walk straight ahead, turn left and you will find the door, enter and on your right side will be the spoons.',
        timestamp: DateTime.now(),
      ),
      TranscriptMessage(
        speaker: 'User',
        text: 'Thank you very much!',
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> _initializeServices() async {
    await _cameraService.initialize();
    await _speechService.initialize();
    setState(() {});
  }

  void _toggleListening() async {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      await _speechService.startListening((recognizedWords) {
        if (recognizedWords.isNotEmpty) {
          setState(() {
            _messages.add(TranscriptMessage(
              speaker: 'User',
              text: recognizedWords,
              timestamp: DateTime.now(),
            ));
          });
          _processCommand(recognizedWords);
        }
      });
    } else {
      await _speechService.stopListening();
    }
  }

  Future<void> _processCommand(String command) async {
    final response = await _apiService.sendVoiceCommand(command);
    setState(() {
      _messages.add(TranscriptMessage(
        speaker: 'Assistant',
        text: response,
        timestamp: DateTime.now(),
      ));
    });
    await _speechService.speak(response);
  }

  void _handleStop() async {
    await _speechService.stop();
    setState(() {
      _isListening = false;
      _messages.clear();
    });
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _speechService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final totalHeight = media.size.height;
    final statusBar = media.padding.top;
    final bottomInset = media.padding.bottom;
    final appBarHeight = const TopNavBar().preferredSize.height;

    // Adjust if your custom BottomNavBar uses a different height.
    const bottomBarHeight = kBottomNavigationBarHeight;

    // Height available for the body (camera + transcript)
    final bodyHeight =
        totalHeight - statusBar - appBarHeight - bottomBarHeight - bottomInset;

    // Target: transcript + bottom bar ≈ 30% of total screen
    final desiredPanel = (totalHeight * 0.30) - bottomBarHeight - bottomInset;

    // Clamp to avoid extremes
    final panelHeight = desiredPanel.clamp(120.0, bodyHeight - 120.0);
    final cameraHeight = bodyHeight - panelHeight;

    return Scaffold(
      appBar: const TopNavBar(),
      body: Column(
        children: [
          SizedBox(
            height: cameraHeight,
            child: Stack(
              children: [
                if (_cameraService.controller != null &&
                    _cameraService.controller!.value.isInitialized)
                  SizedBox.expand(
                    child: CameraPreview(_cameraService.controller!),
                  )
                else
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF239B56),
                      ),
                    ),
                  ),
                Center(
                  child: GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? const Color(0xFF2ECC71)
                            : Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // STOP button at the bottom with padding
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _handleStop,
                      icon: const Icon(Icons.stop, color: Colors.white),
                      label: const Text(
                        'STOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: bottomBarHeight + bottomInset,
        child: BottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
        ),
      ),
    );
  }
}
