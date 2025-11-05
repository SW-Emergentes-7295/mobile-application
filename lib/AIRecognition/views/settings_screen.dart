import 'package:flutter/material.dart';
import 'package:visualguide/shared/widgets/top_nav_bar.dart';
import 'package:visualguide/shared/widgets/bottom_nav_bar.dart';
import 'package:visualguide/AIRecognition/widgets/settings_card.dart';
import 'package:visualguide/AIRecognition/widgets/custom_slider.dart';
import 'package:visualguide/AIRecognition/models/app_settings.dart';
import 'package:visualguide/AIRecognition/services/settings_service.dart';
import 'package:visualguide/AIRecognition/services/speech_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final SpeechService _speechService = SpeechService();
  late AppSettings _settings;
  bool _isLoading = true;
  int _currentNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _speechService.initialize();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final success = await _settingsService.saveSettings(_settings);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada exitosamente'),
          backgroundColor: Color(0xFF239B56),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateSpeechRate(double value) {
    setState(() {
      _settings = _settings.copyWith(speechRate: value);
    });
    _saveSettings();
    // TODO: Aplicar cambio al servicio de voz
    _speechService.setSpeechRate(value);
  }

  void _updateObstacleSensitivity(double value) {
    setState(() {
      _settings = _settings.copyWith(obstacleSensitivity: value);
      // Determinar nivel de sensibilidad
      if (value < 0.33) {
        _settings = _settings.copyWith(sensitivityLevel: 'low');
      } else if (value < 0.66) {
        _settings = _settings.copyWith(sensitivityLevel: 'medium');
      } else {
        _settings = _settings.copyWith(sensitivityLevel: 'high');
      }
    });
    _saveSettings();
  }

  void _toggleMiniModel(bool value) {
    setState(() {
      _settings = _settings.copyWith(miniModelEnabled: value);
    });
    _saveSettings();
    // TODO: Activar/desactivar modelo mini en el backend
  }

  void _selectVoiceTone(String tone) {
    setState(() {
      _settings = _settings.copyWith(voiceTone: tone);
    });
    _saveSettings();
    // TODO: Aplicar tono de voz seleccionado
  }

  void _linkFamiliarConnection() {
    // TODO: Implementar lógica de vinculación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular conexión familiar'),
        content: const Text('Funcionalidad en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF239B56),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const TopNavBar(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Título
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: const Text(
              'CONFIGURATION',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),

          // Contenido scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Voice Preference Card
                  SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voice preference',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Rate of speech',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomSlider(
                          value: _settings.speechRate,
                          onChanged: _updateSpeechRate,
                          label: '${(_settings.speechRate * 100).toInt()}%',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Tone of voice',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildToneChip('Serious', 'serious'),
                            const SizedBox(width: 8),
                            _buildToneChip('Clear', 'clear'),
                            const SizedBox(width: 8),
                            _buildToneChip('Fast', 'fast'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Navigational Assistance Card
                  SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Navigational Assistance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Obstacle sensivity',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomSlider(
                          value: _settings.obstacleSensitivity,
                          onChanged: _updateObstacleSensitivity,
                          label:
                              '${(_settings.obstacleSensitivity * 100).toInt()}%',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sensivity ${_settings.sensitivityLevel}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Model Configuration Card
                  SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Model Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mini Model Toggle
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.graphic_eq,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'VisualGuide-mini-01',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Our mini model is growing\nand learning with you\nevery day!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: _settings.miniModelEnabled,
                                onChanged: _toggleMiniModel,
                                activeColor: const Color(0xFF239B56),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Familiar Connection
                        Row(
                          children: [
                            const Icon(
                              Icons.check,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Familiar connection',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _settings.familiarConnectionName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'ID: ${_settings.familiarConnectionId}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _linkFamiliarConnection,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Link to',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Espacio para el navbar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index != 2) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildToneChip(String label, String value) {
    final isSelected = _settings.voiceTone == value;
    return GestureDetector(
      onTap: () => _selectVoiceTone(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF239B56) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speechService.stop();
    super.dispose();
  }
}
