import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:visualguide/AIRecognition/views/settings_screen.dart';
import 'package:visualguide/shared/widgets/top_nav_bar.dart';
import 'package:visualguide/shared/widgets/bottom_nav_bar.dart';
import 'package:visualguide/AIRecognition/widgets/transcript_panel.dart';
import 'package:visualguide/AIRecognition/models/transcript_message.dart';
import 'package:visualguide/AIRecognition/services/camera_service.dart';
import 'package:visualguide/AIRecognition/services/speech_service.dart';
import 'package:visualguide/AIRecognition/services/api_service.dart';
import 'package:visualguide/AIRecognition/services/spatial_service.dart';
import 'package:visualguide/AIRecognition/models/spatial_data.dart';
import 'package:visualguide/AIRecognition/models/detected_object.dart';
import 'package:visualguide/AIRecognition/widgets/spatial_overlay.dart';
import 'package:visualguide/AIRecognition/models/navigation_instruction.dart';
import 'dart:async';

class AIRecognitionScreen extends StatefulWidget {
  const AIRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<AIRecognitionScreen> createState() => _AIRecognitionScreenState();
}

class _AIRecognitionScreenState extends State<AIRecognitionScreen> {
  final CameraService _cameraService = CameraService();
  final SpeechService _speechService = SpeechService();
  final ApiService _apiService = ApiService();
  final SpatialService _spatialService = SpatialService();

  int _currentNavIndex = 1;
  bool _isListening = false;
  List<TranscriptMessage> _messages = [];
  String _messageInProcess = ''; // show live transcription

  // Datos espaciales
  SpatialData? _currentSpatialData;
  List<DetectedObject> _detectedObjects = [];
  NavigationInstruction? _currentInstruction;
  String? _targetRoom;

  // Timer para detección continua
  Timer? _detectionTimer;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
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
    await _spatialService.initialize();

    // Iniciar detección continua cada 2 segundos
    _startContinuousDetection();

    setState(() {});
  }

  void _startContinuousDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isProcessing && _cameraService.controller != null) {
        _performObjectDetection();
      }
    });
  }

  Future<void> _performObjectDetection() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capturar frame de la cámara
      final imagePath = await _cameraService.takePicture();

      if (imagePath != null) {
        // Obtener dimensiones de la imagen
        final controller = _cameraService.controller!;
        final imageWidth = controller.value.previewSize!.width;
        final imageHeight = controller.value.previewSize!.height;

        // Detectar objetos con la API
        final detections = await _apiService.detectObjectsWithSpatialData(
          imagePath: imagePath,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        );

        if (detections.isNotEmpty) {
          // Procesar detecciones con el servicio espacial
          final spatialData = await _spatialService.processDetections(
            detections: detections
                .map((obj) => {
                      'label': obj.label,
                      'confidence': obj.confidence,
                      'bbox': [
                        obj.boundingBox.x * imageWidth,
                        obj.boundingBox.y * imageHeight,
                        obj.boundingBox.width * imageWidth,
                        obj.boundingBox.height * imageHeight,
                      ],
                    })
                .toList(),
            imageHeight: imageHeight,
            imageWidth: imageWidth,
          );

          // Actualizar ubicación actual
          _spatialService.updateCurrentLocation(detections);

          setState(() {
            _currentSpatialData = spatialData;
            _detectedObjects = detections;
          });

          // Generar alertas de proximidad
          final alerts = _spatialService.generateProximityAlerts(spatialData);
          for (var alert in alerts) {
            await _speechService.speak(alert);
          }

          // Si hay un objetivo, generar instrucciones
          if (_targetRoom != null) {
            _generateNavigationInstructions();
          }
        }
      }
    } catch (e) {
      print('Error en detección: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _generateNavigationInstructions() async {
    if (_currentSpatialData == null || _targetRoom == null) return;

    // Generar instrucción localmente
    final localInstruction = _spatialService.generateNavigationInstruction(
      targetRoom: _targetRoom!,
      spatialData: _currentSpatialData!,
    );

    // Intentar obtener instrucción del backend (más precisa)
    final apiInstruction = await _apiService.getNavigationInstructions(
      currentLocation: _spatialService.currentLocation,
      targetRoom: _targetRoom!,
      nearbyObjects: _detectedObjects,
    );

    setState(() {
      _currentInstruction = apiInstruction ?? localInstruction;
    });

    // Reproducir instrucción si es de alta prioridad
    if (_currentInstruction!.priority == 'high') {
      await _speechService.speak(_currentInstruction!.getFullInstruction());

      // Agregar a transcripción
      setState(() {
        _messages.add(TranscriptMessage(
          speaker: 'Assistant',
          text: _currentInstruction!.getFullInstruction(),
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  void _toggleListening() async {
    setState(() => _isListening = !_isListening);

    if (_isListening) {
      _messageInProcess = '';
      await _speechService.startListening(
        (recognizedWords) {
          // interim (live) transcription
          if (recognizedWords.isNotEmpty) {
            setState(() {
              _messageInProcess = recognizedWords;
            });
          }
        },
        onFinalResult: (finalText) {
          // final recognized text
          if (finalText.isNotEmpty) {
            setState(() {
              _messages.add(TranscriptMessage(
                speaker: 'User',
                text: finalText,
                timestamp: DateTime.now(),
              ));
              _messageInProcess = '';
            });
            _processCommand(finalText);
          }
        },
      );
    } else {
      await _speechService.stopListening();
      // finalize mid-utterance if any
      if (_messageInProcess.isNotEmpty) {
        setState(() {
          _messages.add(TranscriptMessage(
            speaker: 'User',
            text: _messageInProcess,
            timestamp: DateTime.now(),
          ));
          _messageInProcess = '';
        });
      }
    }
  }

  Future<void> _processCommand(String command) async {
    // Detectar si el usuario quiere ir a alguna habitación
    final lowerCommand = command.toLowerCase();

    if (lowerCommand.contains('cocina') || lowerCommand.contains('kitchen')) {
      _targetRoom = 'kitchen';
      await _speechService.speak('Entendido, te guiaré a la cocina');
    } else if (lowerCommand.contains('dormitorio') ||
        lowerCommand.contains('bedroom')) {
      _targetRoom = 'bedroom';
      await _speechService.speak('Entendido, te guiaré al dormitorio');
    } else if (lowerCommand.contains('baño') ||
        lowerCommand.contains('bathroom')) {
      _targetRoom = 'bathroom';
      await _speechService.speak('Entendido, te guiaré al baño');
    } else if (lowerCommand.contains('sala') ||
        lowerCommand.contains('living')) {
      _targetRoom = 'living_room';
      await _speechService.speak('Entendido, te guiaré a la sala');
    }

    // Procesar comando con la API
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
    await _speechService.stopListening();
    _targetRoom = null;
    setState(() {
      _isListening = false;
      _currentInstruction = null;
      // finalize in-progress
      if (_messageInProcess.isNotEmpty) {
        _messages.add(TranscriptMessage(
          speaker: 'User',
          text: _messageInProcess,
          timestamp: DateTime.now(),
        ));
        _messageInProcess = '';
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Service stopped successfully')),
            ],
          ),
          backgroundColor: const Color(0xFF239B56),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _handleNavigation(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _cameraService.dispose();
    _speechService.stop();
    _spatialService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      body: Stack(
        children: [
          // Camera preview
          if (_cameraService.controller != null &&
              _cameraService.controller!.value.isInitialized)
            SizedBox.expand(child: CameraPreview(_cameraService.controller!))
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF239B56)),
              ),
            ),

          // Overlay
          if (_detectedObjects.isNotEmpty)
            SpatialOverlay(
              detectedObjects: _detectedObjects,
              currentLocation: _spatialService.currentLocation,
              targetRoom: _targetRoom,
            ),

          // Mic button centered
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
                child: const Icon(Icons.mic_rounded,
                    size: 60, color: Colors.white),
              ),
            ),
          ),

          // Transcript panel at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: TranscriptPanel(
              messages: _messages,
              inProgressText: _messageInProcess,
              onStop: _handleStop,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}
