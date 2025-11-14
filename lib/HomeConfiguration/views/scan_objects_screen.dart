import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ScanningObjectScreen extends StatefulWidget {
  const ScanningObjectScreen({Key? key}) : super(key: key);

  @override
  State<ScanningObjectScreen> createState() => _ScanningObjectScreenState();
}

class _ScanningObjectScreenState extends State<ScanningObjectScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  String _scanningText = 'We are scanning the object in front,\nplease do not leave the object plane.';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void updateScanningText(String newText) {
    setState(() {
      _scanningText = newText;
    });
  }

  void _stopScanning() {
    // Aquí va la lógica para detener el escaneo
    updateScanningText('Scanning stopped');
  }

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
                ],
              ),
            ),

            // Botón Back
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Vista de cámara con marco de escaneo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Vista de cámara
                        _isCameraInitialized && _cameraController != null
                            ? CameraPreview(_cameraController!)
                            : Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        // Marco de escaneo con esquinas
                        Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: CustomPaint(
                            painter: ScanningFramePainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Texto "Scanning object..."
            const Text(
              'Scanning object...',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Texto dinámico de instrucciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                _scanningText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Botón STOP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _stopScanning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB85C5C),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'STOP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// CustomPainter para dibujar las esquinas del marco de escaneo
class ScanningFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5B9BD5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 40.0;
    const radius = 20.0;

    // Esquina superior izquierda
    final pathTopLeft = Path();
    pathTopLeft.moveTo(cornerLength, 0);
    pathTopLeft.lineTo(radius, 0);
    pathTopLeft.arcToPoint(
      const Offset(0, radius),
      radius: const Radius.circular(radius),
    );
    pathTopLeft.lineTo(0, cornerLength);
    canvas.drawPath(pathTopLeft, paint);

    // Esquina superior derecha
    final pathTopRight = Path();
    pathTopRight.moveTo(size.width - cornerLength, 0);
    pathTopRight.lineTo(size.width - radius, 0);
    pathTopRight.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    pathTopRight.lineTo(size.width, cornerLength);
    canvas.drawPath(pathTopRight, paint);

    // Esquina inferior izquierda
    final pathBottomLeft = Path();
    pathBottomLeft.moveTo(0, size.height - cornerLength);
    pathBottomLeft.lineTo(0, size.height - radius);
    pathBottomLeft.arcToPoint(
      Offset(radius, size.height),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    pathBottomLeft.lineTo(cornerLength, size.height);
    canvas.drawPath(pathBottomLeft, paint);

    // Esquina inferior derecha
    final pathBottomRight = Path();
    pathBottomRight.moveTo(size.width, size.height - cornerLength);
    pathBottomRight.lineTo(size.width, size.height - radius);
    pathBottomRight.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
    );
    pathBottomRight.lineTo(size.width - cornerLength, size.height);
    canvas.drawPath(pathBottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}