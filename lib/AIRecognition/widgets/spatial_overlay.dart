// ===================================
// widgets/spatial_overlay.dart
// ===================================
import 'package:flutter/material.dart';
import 'package:visualguide/AIRecognition/models/detected_object.dart';

class SpatialOverlay extends StatelessWidget {
  final List<DetectedObject> detectedObjects;
  final String currentLocation;
  final String? targetRoom;

  const SpatialOverlay({
    Key? key,
    required this.detectedObjects,
    required this.currentLocation,
    this.targetRoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Información de ubicación actual
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF2ECC71),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatLocationName(currentLocation),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Objetivo si existe
        if (targetRoom != null)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF239B56).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hacia: ${_formatLocationName(targetRoom!)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Objetos detectados con distancias
        ...detectedObjects.where((obj) => obj.distance < 5.0).map((obj) {
          return _buildObjectMarker(obj, context);
        }).toList(),

        // Panel de resumen en la parte superior central
        if (detectedObjects.isNotEmpty)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${detectedObjects.length} objetos detectados',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...detectedObjects.take(3).map((obj) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _formatObjectName(obj.label),
                                style: TextStyle(
                                  color: _getAlertColor(obj.getAlertLevel()),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '${obj.distance.toStringAsFixed(1)}m',
                              style: TextStyle(
                                color: _getAlertColor(obj.getAlertLevel()),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildObjectMarker(DetectedObject obj, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final alertLevel = obj.getAlertLevel();

    // Convertir posición normalizada a píxeles
    double left = obj.boundingBox.x * screenSize.width;
    double top = obj.boundingBox.y * screenSize.height;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getAlertColor(alertLevel).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatObjectName(obj.label),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${obj.distance.toStringAsFixed(1)}m',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(String alertLevel) {
    switch (alertLevel) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return const Color(0xFF2ECC71);
      default:
        return Colors.blue;
    }
  }

  String _formatLocationName(String location) {
    Map<String, String> translations = {
      'kitchen': 'Cocina',
      'bedroom': 'Dormitorio',
      'bathroom': 'Baño',
      'living_room': 'Sala',
      'hallway': 'Pasillo',
      'unknown': 'Ubicación desconocida',
    };
    return translations[location] ?? location;
  }

  String _formatObjectName(String label) {
    Map<String, String> translations = {
      'chair': 'Silla',
      'table': 'Mesa',
      'door': 'Puerta',
      'sofa': 'Sofá',
      'bed': 'Cama',
      'person': 'Persona',
      'counter': 'Mostrador',
      'cabinet': 'Gabinete',
      'shelf': 'Estante',
      'stove': 'Estufa',
      'refrigerator': 'Refrigerador',
      'sink': 'Lavabo',
    };
    return translations[label.toLowerCase()] ?? label;
  }
}
