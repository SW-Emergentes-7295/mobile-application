import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/trip_model.dart';

class TripMapView extends StatefulWidget {
  final Trip trip;
  const TripMapView({super.key, required this.trip});

  @override
  State<TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends State<TripMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: false);

    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _pointAlongPath(Size size, double t) {
    final p0 = Offset(size.width * 0.15, size.height * 0.85);
    final p1 = Offset(size.width * 0.3, size.height * 0.6);
    final p2 = Offset(size.width * 0.6, size.height * 0.5);
    final p3 = Offset(size.width * 0.78, size.height * 0.2);

    final x = (1 - t) * (1 - t) * (1 - t) * p0.dx +
        3 * (1 - t) * (1 - t) * t * p1.dx +
        3 * (1 - t) * t * t * p2.dx +
        t * t * t * p3.dx;

    final y = (1 - t) * (1 - t) * (1 - t) * p0.dy +
        3 * (1 - t) * (1 - t) * t * p1.dy +
        3 * (1 - t) * t * t * p2.dy +
        t * t * t * p3.dy;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text("${trip.titulo} Route"),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Imagen del plano con escala reducida
              Center(
                child: Transform.scale(
                  scale: 0.8, // <-- Ajusta este valor (0.7, 0.8, 0.9)
                  child: Image.asset(
                    'assets/floorplan.png',
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),

              // Dibujo del camino
              CustomPaint(
                painter: SmoothRoutePainter(progress: _progress.value),
                size: Size.infinite,
              ),

              // Punto móvil (posición actual)
              Positioned(
                left: _pointAlongPath(
                        MediaQuery.of(context).size, _progress.value)
                    .dx,
                top: _pointAlongPath(
                        MediaQuery.of(context).size, _progress.value)
                    .dy,
                child: const Icon(Icons.circle, color: Colors.red, size: 18),
              ),

              // Panel de información
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.titulo,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("📅 ${trip.fecha}"),
                      Text("🕓 ${trip.hora}"),
                      Text("📍 ${trip.lugar}"),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SmoothRoutePainter extends CustomPainter {
  final double progress;
  SmoothRoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final p0 = Offset(size.width * 0.15, size.height * 0.85);
    final p1 = Offset(size.width * 0.3, size.height * 0.6);
    final p2 = Offset(size.width * 0.6, size.height * 0.5);
    final p3 = Offset(size.width * 0.78, size.height * 0.2);

    path.moveTo(p0.dx, p0.dy);
    path.cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final pathMetrics = path.computeMetrics().first;
    final extract = pathMetrics.extractPath(0, pathMetrics.length * progress);

    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(size.width, size.height),
        [Colors.greenAccent, Colors.green.shade900],
      );

    canvas.drawPath(extract, paint);
  }

  @override
  bool shouldRepaint(covariant SmoothRoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
