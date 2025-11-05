import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      // Usar cámara trasera (índice 0 generalmente)
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
    }
  }

  CameraController? get controller => _controller;

  Future<void> dispose() async {
    await _controller?.dispose();
  }

  Future<String?> takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();
      return image.path;
    }
    return null;
  }
}
