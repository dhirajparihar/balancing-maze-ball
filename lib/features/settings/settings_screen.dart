/// Settings screen — audio volume, haptics, tilt controls, graphics, and data reset.
library;

import 'package:flutter/material.dart';
import '../../core/services/game_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/neon_button.dart';

class SettingsScreen extends StatefulWidget {
  final GameService gameService;

  const SettingsScreen({super.key, required this.gameService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _musicVol;
  late double _sfxVol;
  late bool _vibration;
  late bool _accelerometer;
  late double _sensitivity;
  late String _graphics;
  late bool _reducedMotion;
  late bool _leftHanded;

  @override
  void initState() {
    super.initState();
    final p = widget.gameService.playerData;
    _musicVol = p.musicVolume;
    _sfxVol = p.sfxVolume;
    _vibration = p.vibrationEnabled;
    _accelerometer = p.accelerometerEnabled;
    _sensitivity = p.controlSensitivity;
    _graphics = p.graphicsQuality;
    _reducedMotion = p.reducedMotion;
    _leftHanded = p.leftHandedLayout;
  }

  void _saveSettings() {
    widget.gameService.updateSettings(
      musicVolume: _musicVol,
      sfxVolume: _sfxVol,
      vibrationEnabled: _vibration,
      accelerometerEnabled: _accelerometer,
      controlSensitivity: _sensitivity,
      graphicsQuality: _graphics,
      reducedMotion: _reducedMotion,
      leftHandedLayout: _leftHanded,
    );
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E30),
        title: const Text('Reset All Progress?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently erase all level stars, scores, and unlocked items. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF1744)),
            onPressed: () async {
              await widget.gameService.resetProgress();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('RESET EVERYTHING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08121E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _saveSettings();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  const Text(
                    'SETTINGS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Audio Section
                  _buildSectionHeader('AUDIO & HAPTICS'),
                  const SizedBox(height: 8),
                  GlassPanel(
                    child: Column(
                      children: [
                        _buildSliderRow(
                          'Music Volume',
                          _musicVol,
                          (v) {
                            setState(() => _musicVol = v);
                            _saveSettings();
                          },
                          icon: Icons.music_note,
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        _buildSliderRow(
                          'SFX Volume',
                          _sfxVol,
                          (v) {
                            setState(() => _sfxVol = v);
                            _saveSettings();
                          },
                          icon: Icons.volume_up,
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        _buildSwitchRow(
                          'Vibration Feedback',
                          _vibration,
                          (v) {
                            setState(() => _vibration = v);
                            _saveSettings();
                          },
                          icon: Icons.vibration,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Controls Section
                  _buildSectionHeader('CONTROLS'),
                  const SizedBox(height: 8),
                  GlassPanel(
                    child: Column(
                      children: [
                        _buildSwitchRow(
                          'Device Tilt (Accelerometer)',
                          _accelerometer,
                          (v) {
                            setState(() => _accelerometer = v);
                            _saveSettings();
                          },
                          icon: Icons.screen_rotation,
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        _buildSwitchRow(
                          'Left-Handed Layout (Mirror Sliders)',
                          _leftHanded,
                          (v) {
                            setState(() => _leftHanded = v);
                            _saveSettings();
                          },
                          icon: Icons.front_hand_outlined,
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        _buildSliderRow(
                          'Sensitivity: ${(_sensitivity * 100).toInt()}%',
                          (_sensitivity - 0.3) / 1.7,
                          (v) {
                            setState(() => _sensitivity = 0.3 + v * 1.7);
                            _saveSettings();
                          },
                          icon: Icons.speed,
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        GestureDetector(
                          onTap: () {
                            widget.gameService.playerData.tutorialCompleted = false;
                            widget.gameService.save();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tutorial reset! Play Level 1 to view tutorial again.'),
                                backgroundColor: Color(0xFF00E5FF),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                              border: Border.all(color: const Color(0xFF00E5FF), width: 1.0),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school_rounded, color: Color(0xFF00E5FF), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'RESET & REPLAY TUTORIAL',
                                  style: TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Visuals Section
                  _buildSectionHeader('GRAPHICS & PERFORMANCE'),
                  const SizedBox(height: 8),
                  GlassPanel(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.tune, color: Color(0xFF00E5FF), size: 20),
                                SizedBox(width: 10),
                                Text('Quality Preset', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            DropdownButton<String>(
                              dropdownColor: const Color(0xFF102030),
                              value: _graphics,
                              underline: const SizedBox(),
                              style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                              items: const [
                                DropdownMenuItem(value: 'low', child: Text('Low (Fast)')),
                                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                DropdownMenuItem(value: 'high', child: Text('High (60 FPS)')),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _graphics = v);
                                  _saveSettings();
                                }
                              },
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        _buildSwitchRow(
                          'Reduced Motion',
                          _reducedMotion,
                          (v) {
                            setState(() => _reducedMotion = v);
                            _saveSettings();
                          },
                          icon: Icons.motion_photos_off,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Reset Data Button
                  NeonButton(
                    onPressed: _confirmResetData,
                    primaryColor: const Color(0xFFFF5252),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('RESET PROGRESS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF00E5FF),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildSliderRow(String title, double val, ValueChanged<double> onChanged, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 20),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: 6,
          child: Slider(
            value: val.clamp(0.0, 1.0),
            onChanged: onChanged,
            activeColor: const Color(0xFF00E5FF),
            inactiveColor: Colors.white12,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String title, bool val, ValueChanged<bool> onChanged, {required IconData icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00E5FF), size: 20),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        Switch(
          value: val,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF00E5FF),
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}
