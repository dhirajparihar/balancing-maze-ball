/// Settings screen — matches Reference Screen 12:
/// Header, Music toggle, Sound Effects toggle, Haptic Feedback toggle,
/// Sensitivity slider, Graphics Quality dropdown, Privacy Policy, Credits.
library;

import 'package:flutter/material.dart';
import '../../core/services/game_service.dart';

class SettingsScreen extends StatefulWidget {
  final GameService gameService;

  const SettingsScreen({super.key, required this.gameService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _musicEnabled;
  late bool _sfxEnabled;
  late bool _hapticEnabled;
  late double _sensitivity;
  late String _graphicsQuality;

  @override
  void initState() {
    super.initState();
    final p = widget.gameService.playerData;
    _musicEnabled = p.musicVolume > 0.05;
    _sfxEnabled = p.sfxVolume > 0.05;
    _hapticEnabled = p.vibrationEnabled;
    _sensitivity = p.controlSensitivity.clamp(0.5, 2.0);
    _graphicsQuality = p.graphicsQuality;
  }

  void _saveSettings() {
    widget.gameService.updateSettings(
      musicVolume: _musicEnabled ? 0.7 : 0.0,
      sfxVolume: _sfxEnabled ? 1.0 : 0.0,
      vibrationEnabled: _hapticEnabled,
      controlSensitivity: _sensitivity,
      graphicsQuality: _graphicsQuality,
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0C2438),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
        ),
        title: const Text(
          'PRIVACY POLICY',
          style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Balance Runner respects your privacy. All game progression, scores, records, and settings are stored locally on your device.\n\nNo personal identifying data or location data is gathered or sold to third parties.\n\nEnjoy the game and aim for the top distance on the leaderboards!',
            style: TextStyle(color: Color(0xFFE0F7FA), fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCredits() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0C2438),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
        ),
        title: const Text(
          'CREDITS',
          style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BALANCE RUNNER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('Game Design & Engineering:', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13)),
            Text('Dhiraj Parihar', style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 8),
            Text('Physics Engine: Flame & Custom Lever Engine', style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text('Aesthetics: Glowing Cyan Neon & Cyber Void', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061019),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00E5FF), size: 20),
                    onPressed: () {
                      _saveSettings();
                      Navigator.of(context).pop();
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'SETTINGS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                        shadows: [
                          Shadow(color: Color(0xFF00E5FF), blurRadius: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Audio & Haptic Toggles Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1826),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        // Music
                        _buildSwitchRow(
                          icon: Icons.music_note,
                          title: 'Music',
                          value: _musicEnabled,
                          onChanged: (val) {
                            setState(() => _musicEnabled = val);
                            _saveSettings();
                          },
                        ),
                        const Divider(color: Colors.white10),

                        // Sound Effects
                        _buildSwitchRow(
                          icon: Icons.volume_up,
                          title: 'Sound Effects',
                          value: _sfxEnabled,
                          onChanged: (val) {
                            setState(() => _sfxEnabled = val);
                            _saveSettings();
                          },
                        ),
                        const Divider(color: Colors.white10),

                        // Haptic Feedback
                        _buildSwitchRow(
                          icon: Icons.settings,
                          title: 'Haptic Feedback',
                          value: _hapticEnabled,
                          onChanged: (val) {
                            setState(() => _hapticEnabled = val);
                            _saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sensitivity Slider Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1826),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sensitivity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: const Color(0xFF00E5FF),
                            inactiveTrackColor: Colors.white12,
                            thumbColor: Colors.white,
                            overlayColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            value: _sensitivity,
                            min: 0.5,
                            max: 2.0,
                            onChanged: (val) {
                              setState(() => _sensitivity = val);
                              _saveSettings();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Graphics Quality Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1826),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Graphics Quality',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _graphicsQuality,
                          dropdownColor: const Color(0xFF0A1826),
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                          items: const [
                            DropdownMenuItem(value: 'high', child: Text('High')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _graphicsQuality = val);
                              _saveSettings();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // PRIVACY POLICY Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _showPrivacyPolicy,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text(
                        'PRIVACY POLICY',
                        style: TextStyle(
                          color: Color(0xFF80DEEA),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CREDITS Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _showCredits,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text(
                        'CREDITS',
                        style: TextStyle(
                          color: Color(0xFF80DEEA),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF00E5FF),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
