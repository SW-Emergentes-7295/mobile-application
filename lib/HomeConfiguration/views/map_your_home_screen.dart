import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_tts/flutter_tts.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/top_nav_bar.dart';

class MapYourHomeScreen extends StatefulWidget {
  const MapYourHomeScreen({Key? key}) : super(key: key);

  @override
  State<MapYourHomeScreen> createState() => _MapYourHomeScreenState();
}

class _MapYourHomeScreenState extends State<MapYourHomeScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  String _dynamicText =
      'Some images of your home, will help us to guide you in your day to day life.';

  // Text to Speech
  FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;

  // Pasos del mapeo
  int mappingPhase = 0;

  // Variables para el room
  String _roomImagePath = '';

  // Control de captura
  bool _isCapturing = false;
  bool _isMapping = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    setState(() {
      _isSpeaking = true;
    });
    await flutterTts.speak(text);
    setState(() {
      _isSpeaking = false;
    });
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

  Future<void> _releaseCamera() async {
    try {
      await _cameraController?.dispose();
    } catch (_) {}
    _cameraController = null;
    _isCameraInitialized = false;
  }

  @override
  void dispose() {
    _releaseCamera();
    flutterTts.stop();
    super.dispose();
  }

  void _updateText(String newText) {
    setState(() {
      _dynamicText = newText;
    });
  }

  Future<void> _startMapping() async {
    _isMapping = true;
    debugPrint("Deleting previous mapping...");
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory destinyDir =
        Directory(p.join(baseDir.path, "mapping_images"));
    debugPrint("Destiny dir: $destinyDir");
    if (await destinyDir.exists()) {
      await destinyDir.delete(recursive: true);
    }
    final text = "Mapping started. Take a photo of the living room.";
    _updateText(text);
    await _speak(text);
    mappingPhase = 1;
  }

  Future<void> _savePhoto(String path, String phaseName) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory destinyDir =
        Directory(p.join(baseDir.path, "mapping_images", phaseName));
    if (!await destinyDir.exists()) {
      await destinyDir.create(recursive: true);
    }
    final String fileName = p.basename(path);
    final String newPath = p.join(destinyDir.path, fileName);
    final File imageFile = File(path);
    await imageFile.rename(newPath);
    debugPrint("Photo in $path saved in $newPath");
  }

  Future<void> _saveData() async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory mappingDir =
        Directory(p.join(baseDir.path, "mapping_images"));
    final Directory destinyDir =
        Directory(p.join(baseDir.path, "users_mapping", "user_001"));
    if (await destinyDir.exists()) {
      await destinyDir.delete(recursive: true);
    }
    await destinyDir.create(recursive: true);
    final String newPath = p.join(destinyDir.path, "full_mapping_data");
    if (await mappingDir.exists()) {
      await mappingDir.rename(newPath);
    }
    debugPrint("Saving full data in local archives");
  }

  // Show loading animation and then redirect to /aiRecognition
  Future<void> _showMappingProgressAndGo() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(height: 8),
                CircularProgressIndicator(color: Color(0xFF4CAF50)),
                SizedBox(height: 16),
                Text(
                  'Mapping your home...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Brief delay just for UX
    await Future.delayed(const Duration(seconds: 2));

    // Important: release camera before navigating
    await _releaseCamera();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close dialog

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/aiRecognition');
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _updateText('Camera is not ready');
      return;
    }

    if (!_isMapping) {
      _startMapping();
      return;
    } else {
      if (_isCapturing) return;
      setState(() {
        _isCapturing = true;
      });
      try {
        final XFile photo = await _cameraController!.takePicture();
        debugPrint('Photo saved: ${photo.path}');
        _roomImagePath = photo.path;
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error capturing photo: $e');
        _updateText('Error capturing photo. Try again');
      } finally {
        setState(() {
          _isCapturing = false;
        });
      }

      String nextText = '';
      switch (mappingPhase) {
        case 1:
          _savePhoto(_roomImagePath, "living_room");
          nextText = "Now take another photo of the living room";
          mappingPhase = 2;
          break;
        case 2:
          _savePhoto(_roomImagePath, "living_room");
          nextText = "Now take a photo of your bedroom";
          mappingPhase = 3;
          break;
        case 3:
          _savePhoto(_roomImagePath, "bedroom");
          nextText = "Now take another photo of your bedroom";
          mappingPhase = 4;
          break;
        case 4:
          _savePhoto(_roomImagePath, "bedroom");
          nextText = "Now take a photo of your kitchen";
          mappingPhase = 5;
          break;
        case 5:
          _savePhoto(_roomImagePath, "kitchen");
          nextText = "Now take a photo of your dining room";
          mappingPhase = 6;
          break;
        case 6:
          _savePhoto(_roomImagePath, "dining_room");
          nextText = "Now take a photo of your bathroom";
          mappingPhase = 7;
          break;
        case 7:
          _savePhoto(_roomImagePath, "bathroom");
          // Finish mapping: persist data then show animation and redirect
          mappingPhase = 0;
          _isMapping = false;
          await _saveData();

          // Update the visible hint and optionally speak it
          nextText = "Mapping your home...";
          _updateText(nextText);
          await _showMappingProgressAndGo();
          return; // stop further processing
      }
      _updateText(nextText);
      await _speak(nextText);
      return;
    }
  }

  void _speakInstructions() {
    _speak(_dynamicText);
  }

  void _openSettings() {
    debugPrint('Navigating to settings');
    // Navegar a configuración
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Replace the custom gradient header with the shared TopNavBar
      appBar: const TopNavBar(),

      body: SafeArea(
        child: Column(
          children: [
            // Removed the custom top container header here

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Map your\nhome',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dynamic text
                      Text(
                        _dynamicText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Camera view (tap to capture)
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          height: 320,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: _isCameraInitialized &&
                                        _cameraController != null
                                    ? CameraPreview(_cameraController!)
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.camera_alt_rounded,
                                            size: 120,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                              ),
                              if (_isCapturing)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Color(0xFF4CAF50),
                                          strokeWidth: 3,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Capturing...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            Navigator.pop(context);
          }
        },
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
    final size = isLarge ? 80.0 : 64.0;
    final iconSize = isLarge ? 36.0 : 28.0;

    return Column(
      children: [
        Material(
          color: isActive ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(size / 2),
          elevation: isActive ? 12 : 8,
          shadowColor: isActive
              ? const Color(0xFFE53935).withOpacity(0.4)
              : const Color(0xFF4CAF50).withOpacity(0.4),
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
                          width: size * 0.85,
                          height: size * 0.85,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ],
                    )
                  : Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
