import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class MapYourHomeScreen extends StatefulWidget {
  const MapYourHomeScreen({Key? key}) : super(key: key);

  @override
  State<MapYourHomeScreen> createState() => _MapYourHomeScreenState();
}

class _MapYourHomeScreenState extends State<MapYourHomeScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  String _dynamicText = 'Take an image of a room';

  //Pasos del mapeo
  int mapping_phase = 0; //2 en la sala, 2 en el cuarto, 1 en la cocina, 1 del comedor, 1 del baño

  //Variables para el room
  String _roomName = '';
  String _roomImagePath = '';

  // Control de captura
  bool _isCapturing = false;
  bool _isMapping = false;

  // Estados de la aplicación
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _updateText('Error: Could not access camera');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _updateText(String newText) {
    setState(() {
      _dynamicText = newText;
    });
  }

  Future<void> start_mapping() async{
    _isMapping = true;
    debugPrint("Deleting previous mapping...");
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory destinyDir = Directory(p.join(baseDir.path, "mapping_images"));
    debugPrint("Destiny dir: $destinyDir");
    if (await destinyDir.exists()) {
      await destinyDir.delete(recursive: true);
    }
    _updateText("Mapping started. Take a photo of the living room.");
    mapping_phase = 1;
  }

  Future<void> save_photo (String path, String phase_name) async{
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory destinyDir = Directory(p.join(baseDir.path, "mapping_images", phase_name));
    if (!await destinyDir.exists()) {
      await destinyDir.create(recursive: true);
    }
    final String fileName = p.basename(path);
    final String newPath = p.join(destinyDir.path, fileName);
    final File imageFile = File(path);
    await imageFile.rename(newPath);
    debugPrint("Photo in $path saved in $newPath");
  }

  Future<void> save_data() async{
    //TODO: Añadir el user id dinámicamente
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory mappingDir = Directory(p.join(baseDir.path, "mapping_images"));
    final Directory destinyDir = Directory(p.join(baseDir.path, "users_mapping", "user_001"));
    if (await destinyDir.exists()) {
      await destinyDir.delete(recursive: true);
    }
    await destinyDir.create(recursive: true);
    final String newPath = p.join(destinyDir.path, "full_mapping_data");;
    if (await mappingDir.exists()) {
      await mappingDir.rename(newPath);
    }
    debugPrint("Saving full data in local archives");
  }

  // Capturar foto
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _updateText('Camera is not ready');
      return;
    }

    if(!_isMapping){
      start_mapping();
      return;
    } else{
      if (_isCapturing) return;
      setState(() {
        _isCapturing = true;
      });
      try {
        final XFile photo = await _cameraController!.takePicture();
        // Aquí puedes guardar la foto o procesarla
        debugPrint('Photo saved: ${photo.path}');
        _roomImagePath = photo.path;
        // Pausa de medio segundo
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error capturing photo: $e');
        _updateText('Error capturing photo. Try again');
      } finally {
        setState(() {
          _isCapturing = false;
        });
      }
      switch (mapping_phase){
        case 1:
          save_photo(_roomImagePath, "living_room");
          _updateText("Now take a another photo of the living room");
          mapping_phase = 2;
        case 2:
          save_photo(_roomImagePath, "living_room");
          _updateText("Now take a photo of your bedroom");
          mapping_phase = 3;
        case 3:
          save_photo(_roomImagePath, "bedroom");
          _updateText("Now take another photo of your bedroom");
          mapping_phase = 4;
        case 4:
          save_photo(_roomImagePath, "bedroom");
          _updateText("Now take a photo of your kitchen");
          mapping_phase = 5;
        case 5:
          save_photo(_roomImagePath, "kitchen");
          _updateText("Now take a photo of your dinning room");
          mapping_phase = 6;
        case 6:
          save_photo(_roomImagePath, "dinning_room");
          _updateText("Now take a photo of your bathroom");
          mapping_phase = 7;
        case 7:
          save_photo(_roomImagePath, "bathroom");
          _updateText("Mapping ended. Touch camera to start again.");
          mapping_phase = 7;
          _isMapping = false;
          save_data();
      }
      return;
    }
  }

  // Manejar comando de voz (simulado)
  void _handleVoiceCommand() {
    setState(() {
      _isListening = !_isListening;
    });
    if (_isListening) {
      _updateText('Listening... Say "start mapping" or "command to enter another view"');
      // Simular reconocimiento de voz después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (_isListening) {
          // Recibe comando de voz
          _processVoiceCommand('comando de prueba');
        }
      });
    } else {
      _updateText('Voice command cancelled');
    }
  }

  // Procesar comando de voz
  void _processVoiceCommand(String command) {
    setState(() {
      _isListening = false;
    });
    command = command.toLowerCase();
    debugPrint('Voice command received: $command');
    if (command.contains('take photo') || command.contains('capture')) {
      _capturePhoto();
    } else if (command.contains('home')) {
      _goToHome();
    } else {
      _updateText('Command not recognized. Try: "start mapping" or "take photo"');
    }
  }

  // Ir a Home
  void _goToHome() {
    debugPrint('Navigating to Home Screen');
  }

  // Abrir configuración
  void _openSettings() {
    debugPrint('Navigating to setting');
  }

  //-----------------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar personalizado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'VisualGuide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

//Contenido principal ----------------------------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Título
                      const Text(
                        'Map your\nhome',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Texto dinámico
                      Text(
                        _dynamicText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Vista de cámara----------------------------------------------------------------
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: _isCameraInitialized && _cameraController != null
                                    ? CameraPreview(_cameraController!)
                                    : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 100,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),

                              // Indicador de captura
                              if (_isCapturing)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),

                              // Botón de captura manual
                              /*Positioned(
                                bottom: 16,
                                right: 16,
                                child: FloatingActionButton(
                                  onPressed: _capturePhoto,
                                  backgroundColor: Colors.white,
                                  child: const Icon(
                                    Icons.camera,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Botones de navegación-----------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavButton(
                            icon: Icons.home,
                            label: 'HOME',
                            onTap: _goToHome,
                          ),
                          _buildNavButton(
                            icon: _isListening ? Icons.mic : Icons.mic_none,
                            label: 'SPEAK',
                            onTap: _handleVoiceCommand,
                            isLarge: true,
                            isActive: _isListening,
                          ),
                          _buildNavButton(
                            icon: Icons.settings,
                            label: 'SETTINGS',
                            onTap: _openSettings,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLarge = false,
    bool isActive = false,
  }) {
    final size = isLarge ? 80.0 : 60.0;
    final iconSize = isLarge ? 36.0 : 28.0;

    return Column(
      children: [
        Material(
          color: isActive ? Colors.red : const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(size / 2),
          elevation: 8,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 2),
              ),
              child: isActive
                  ? Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: iconSize),
                  SizedBox(
                    width: size * 0.8,
                    height: size * 0.8,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              )
                  : Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}