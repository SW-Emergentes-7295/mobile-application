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
import 'package:visualguide/AIRecognition/services/ai_assistant_service.dart';
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
  final AIAssistantService _aiAssistant = AIAssistantService();

  int _currentNavIndex = 1;
  bool _isListening = false;
  List<TranscriptMessage> _messages = [];
  String _messageInProcess = '';

  // Datos espaciales
  SpatialData? _currentSpatialData;
  List<DetectedObject> _detectedObjects = [];
  List<DetectedObject> _previousDetectedObjects = [];
  NavigationInstruction? _currentInstruction;
  String? _targetRoom;

  // Timer para detección continua
  Timer? _detectionTimer;
  bool _isProcessing = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _cameraService.initialize();
    await _speechService.initialize();
    await _spatialService.initialize();

    // Iniciar detección continua cada 2 segundos
    _startContinuousDetection();

    // Mensaje de bienvenida
    await Future.delayed(const Duration(milliseconds: 500));
    await _speakAndLog(
      'Asistente visual activado. Puedes pedirme que te guíe a cualquier lugar o preguntarme qué hay a tu alrededor.',
      speaker: 'Assistant',
    );

    setState(() {});
  }

  void _startContinuousDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isProcessing && !_isSpeaking && _cameraService.controller != null) {
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

          // Generar alertas proactivas de objetos nuevos/peligrosos
          final proactiveAlert = await _aiAssistant.generateProactiveAlert(
            newObjects: detections,
            previousObjects: _previousDetectedObjects,
            currentLocation: _spatialService.currentLocation,
          );

          if (proactiveAlert != null &&
              proactiveAlert['should_speak_immediately'] == true) {
            await _speakAndLog(
              proactiveAlert['response_text'],
              speaker: 'Assistant',
              priority: proactiveAlert['priority'],
            );
          }

          setState(() {
            _currentSpatialData = spatialData;
            _previousDetectedObjects = List.from(_detectedObjects);
            _detectedObjects = detections;
          });

          // Si hay un objetivo activo, generar instrucciones
          if (_targetRoom != null && !_isSpeaking) {
            await _generateNavigationInstructions();
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

    // Generar instrucción localmente como fallback
    final localInstruction = _spatialService.generateNavigationInstruction(
      targetRoom: _targetRoom!,
      spatialData: _currentSpatialData!,
    );

    // Obtener instrucción del backend con IA
    final apiInstruction = await _apiService.getNavigationInstructions(
      currentLocation: _spatialService.currentLocation,
      targetRoom: _targetRoom!,
      nearbyObjects: _detectedObjects,
    );

    setState(() {
      _currentInstruction = apiInstruction ?? localInstruction;
    });

    // Reproducir instrucción si es de alta prioridad
    if (_currentInstruction!.priority == 'high' && !_isSpeaking) {
      await _speakAndLog(
        _currentInstruction!.getFullInstruction(),
        speaker: 'Assistant',
        priority: 'high',
      );
    }
  }

  void _toggleListening() async {
    setState(() => _isListening = !_isListening);

    if (_isListening) {
      _messageInProcess = '';
      await _speechService.startListening(
        (recognizedWords) {
          // Transcripción en tiempo real
          if (recognizedWords.isNotEmpty) {
            setState(() {
              _messageInProcess = recognizedWords;
            });
          }
        },
        onFinalResult: (finalText) {
          // Texto final reconocido
          if (finalText.isNotEmpty) {
            setState(() {
              _messages.add(TranscriptMessage(
                speaker: 'User',
                text: finalText,
                timestamp: DateTime.now(),
              ));
              _messageInProcess = '';
            });
            _processCommandWithAI(finalText);
          }
        },
      );
    } else {
      await _speechService.stopListening();
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

  /// Procesa comandos usando el asistente de IA con contexto completo
  Future<void> _processCommandWithAI(String command) async {
    try {
      // Enviar comando al asistente con todo el contexto espacial
      final response = await _aiAssistant.processVoiceCommandWithContext(
        userCommand: command,
        detectedObjects: _detectedObjects,
        currentLocation: _spatialService.currentLocation,
        targetRoom: _targetRoom,
      );

      // Actualizar objetivo si el usuario pidió ir a algún lugar
      if (response['target_room'] != null) {
        _targetRoom = response['target_room'];
        _aiAssistant.setTargetRoom(_targetRoom);
      }

      // Procesar acción
      final action = response['action'] ?? 'inform';

      if (action == 'stop') {
        _targetRoom = null;
        _aiAssistant.setTargetRoom(null);
      }

      // Hablar respuesta
      if (response['should_speak_immediately'] == true) {
        await _speakAndLog(
          response['response_text'] ?? 'Comando procesado',
          speaker: 'Assistant',
          priority: response['priority'] ?? 'medium',
        );
      }

      // Si hay paso de navegación, guardarlo
      if (response['navigation_step'] != null) {
        final navStep = response['navigation_step'];
        setState(() {
          _currentInstruction = NavigationInstruction(
            action: navStep['direction'] ?? 'forward',
            description: navStep['description'] ?? '',
            distance: (navStep['distance'] ?? 0.0).toDouble(),
            targetRoom: _targetRoom ?? '',
            obstacles:
                _detectedObjects.where((obj) => obj.distance < 2.0).toList(),
            priority: response['priority'] ?? 'medium',
            timestamp: DateTime.now(),
          );
        });
      }
    } catch (e) {
      print('Error procesando comando con IA: $e');
      await _speakAndLog(
        'Lo siento, tuve un problema procesando tu comando.',
        speaker: 'Assistant',
      );
    }
  }

  /// Habla y registra en la transcripción
  Future<void> _speakAndLog(
    String text, {
    String speaker = 'Assistant',
    String priority = 'medium',
  }) async {
    if (_isSpeaking) return;

    setState(() {
      _isSpeaking = true;
      _messages.add(TranscriptMessage(
        speaker: speaker,
        text: text,
        timestamp: DateTime.now(),
      ));
    });

    await _speechService.speak(text);

    // Esperar un poco después de hablar
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSpeaking = false;
    });
  }

  void _handleStop() async {
    await _speechService.stopListening();
    _targetRoom = null;
    _aiAssistant.setTargetRoom(null);

    setState(() {
      _isListening = false;
      _currentInstruction = null;

      if (_messageInProcess.isNotEmpty) {
        _messages.add(TranscriptMessage(
          speaker: 'User',
          text: _messageInProcess,
          timestamp: DateTime.now(),
        ));
        _messageInProcess = '';
      }
    });

    await _speakAndLog('Navegación detenida', speaker: 'Assistant');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Servicio detenido correctamente')),
            ],
          ),
          backgroundColor: const Color(0xFF239B56),
          duration: const Duration(seconds: 2),
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
          // Vista previa de cámara
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

          // Overlay espacial
          if (_detectedObjects.isNotEmpty)
            SpatialOverlay(
              detectedObjects: _detectedObjects,
              currentLocation: _spatialService.currentLocation,
              targetRoom: _targetRoom,
            ),

          // Indicador de procesamiento
          if (_isProcessing)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF2ECC71),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Analizando entorno...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Botón de micrófono centrado
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.mic_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    if (_isListening)
                      Positioned(
                        bottom: 20,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Panel de transcripción
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
