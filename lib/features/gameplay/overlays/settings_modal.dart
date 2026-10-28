/// Settings Modal Overlay — controls sensitivity, relative/absolute drag, audio, haptics.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../game/balancing_maze_game.dart';

class SettingsModal extends StatefulWidget {
  final BalancingMazeGame game;
  final VoidCallback onClose;

  const SettingsModal({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late double _sensitivity;
  late bool _isRelativeDrag;
  late bool _sfxEnabled;
  late bool _musicEnabled;
  late bool _hapticsEnabled;
  late bool _leftHanded;
  late bool _reducedMotion;

  @override
  void initState() {
    super.initState();
    final pData = widget.game.gameService.playerData;
    _sensitivity = widget.game.controlSensitivity;
    _isRelativeDrag = widget.game.isRelativeDrag;
    _sfxEnabled = pData.sfxVolume > 0.05;
    _musicEnabled = pData.musicVolume > 0.05;
    _hapticsEnabled = pData.vibrationEnabled;
    _leftHanded = pData.leftHandedLayout;
    _reducedMotion = pData.reducedMotion;
  }

  void _saveSettings() {
    final pData = widget.game.gameService.playerData;
    pData.controlSensitivity = _sensitivity;
    pData.sfxVolume = _sfxEnabled ? 1.0 : 0.0;
    pData.musicVolume = _musicEnabled ? 0.7 : 0.0;
    pData.vibrationEnabled = _hapticsEnabled;
    pData.leftHandedLayout = _leftHanded;
    pData.reducedMotion = _reducedMotion;
    widget.game.controlSensitivity = _sensitivity;
    widget.game.isRelativeDrag = _isRelativeDrag;
    widget.game.gameService.save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.game.currentTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Frosted background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),

          Center(
            child: Container(
              width: 330,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: const Color(0xFF0F1726).withValues(alpha: 0.95),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings_rounded, color: theme.rimColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'SETTINGS',
                            style: TextStyle(
                              color: theme.hudTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          _saveSettings();
                          widget.onClose();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E2D4A),
                          ),
                          child: const Icon(Icons.close_rounded, color: Color(0xFFECEFF1), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sensitivity Setting
                  const Text(
                    'CONTROLS SENSITIVITY',
                    style: TextStyle(
                      color: Color(0xFF90A4AE),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSensitivityPill(0.5, '0.5x Fine'),
                      const SizedBox(width: 8),
                      _buildSensitivityPill(1.0, '1.0x Normal'),
                      const SizedBox(width: 8),
                      _buildSensitivityPill(1.5, '1.5x Fast'),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Relative vs Absolute Drag Toggle
                  const Text(
                    'TOUCH INPUT MODE',
                    style: TextStyle(
                      color: Color(0xFF90A4AE),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTogglePill(
                          label: 'Relative Drag',
                          isSelected: _isRelativeDrag,
                          onTap: () {
                            setState(() => _isRelativeDrag = true);
                            _saveSettings();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTogglePill(
                          label: 'Absolute Track',
                          isSelected: !_isRelativeDrag,
                          onTap: () {
                            setState(() => _isRelativeDrag = false);
                            _saveSettings();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Toggles (SFX, Music, Haptics)
                  _buildSwitchRow(
                    label: 'Sound Effects (SFX)',
                    value: _sfxEnabled,
                    onChanged: (val) {
                      setState(() => _sfxEnabled = val);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchRow(
                    label: 'Background Music',
                    value: _musicEnabled,
                    onChanged: (val) {
                      setState(() => _musicEnabled = val);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchRow(
                    label: 'Haptic Feedback',
                    value: _hapticsEnabled,
                    onChanged: (val) {
                      setState(() => _hapticsEnabled = val);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchRow(
                    label: 'Left-Handed Layout',
                    value: _leftHanded,
                    onChanged: (val) {
                      setState(() => _leftHanded = val);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchRow(
                    label: 'Reduced Motion',
                    value: _reducedMotion,
                    onChanged: (val) {
                      setState(() => _reducedMotion = val);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 24),

                  // DONE Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _saveSettings();
                      widget.onClose();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'DONE',
                          style: TextStyle(
                            color: Color(0xFF041920),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivityPill(double value, String label) {
    final isSelected = (_sensitivity - value).abs() < 0.1;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _sensitivity = value);
          _saveSettings();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                : const Color(0xFF162238),
            border: Border.all(
              color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF263859),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF90A4AE),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTogglePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color(0xFFFFB74D).withValues(alpha: 0.25)
              : const Color(0xFF162238),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFB74D) : const Color(0xFF263859),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFB74D) : const Color(0xFF90A4AE),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFECEFF1),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: const Color(0xFF00E5FF),
          activeThumbColor: Colors.white,
          onChanged: (newVal) {
            HapticFeedback.selectionClick();
            onChanged(newVal);
          },
        ),
      ],
    );
  }
}
