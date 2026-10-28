/// Pause Modal Overlay — glassmorphic pause dialog with Resume, Restart, Settings, and Quit.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../game/balancing_maze_game.dart';

class PauseModal extends StatelessWidget {
  final BalancingMazeGame game;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onOpenSettings;
  final VoidCallback onQuit;

  const PauseModal({
    super.key,
    required this.game,
    required this.onResume,
    required this.onRestart,
    required this.onOpenSettings,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = game.currentTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Frosted background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
              ),
            ),
          ),

          // Center Pause Card
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: const Color(0xFF0F1726).withValues(alpha: 0.94),
                border: Border.all(
                  color: theme.rimGlowColor.withValues(alpha: 0.6),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.rimGlowColor.withValues(alpha: 0.3),
                    blurRadius: 30,
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
                children: [
                  // Icon
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.rimGlowColor.withValues(alpha: 0.15),
                      border: Border.all(
                        color: theme.rimGlowColor.withValues(alpha: 0.7),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.rimGlowColor.withValues(alpha: 0.4),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.pause_rounded,
                      color: theme.hudTextColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title: "GAME PAUSED"
                  Text(
                    'GAME PAUSED',
                    style: TextStyle(
                      color: theme.hudTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(
                          color: theme.rimGlowColor.withValues(alpha: 0.8),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Level ${game.currentLevel.id} • ${game.currentLevel.title}',
                    style: TextStyle(
                      color: const Color(0xFF90A4AE),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // RESUME Button
                  _buildActionButton(
                    label: 'RESUME ▶',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                    ),
                    borderColor: const Color(0xFFFFD54F),
                    textColor: const Color(0xFF3E2723),
                    isPrimary: true,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onResume();
                    },
                  ),
                  const SizedBox(height: 12),

                  // RESTART Button
                  _buildActionButton(
                    label: 'RESTART ↺',
                    gradient: LinearGradient(
                      colors: [
                        theme.rimColor.withValues(alpha: 0.2),
                        theme.rimGlowColor.withValues(alpha: 0.3),
                      ],
                    ),
                    borderColor: theme.rimColor.withValues(alpha: 0.6),
                    textColor: const Color(0xFFECEFF1),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onRestart();
                    },
                  ),
                  const SizedBox(height: 12),

                  // SETTINGS Button
                  _buildActionButton(
                    label: 'SETTINGS ⚙',
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF263238).withValues(alpha: 0.4),
                        const Color(0xFF37474F).withValues(alpha: 0.4),
                      ],
                    ),
                    borderColor: const Color(0xFF546E7A).withValues(alpha: 0.5),
                    textColor: const Color(0xFFCFD8DC),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onOpenSettings();
                    },
                  ),
                  const SizedBox(height: 12),

                  // QUIT TO MENU
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onQuit();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'QUIT TO MENU',
                        style: TextStyle(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
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

  Widget _buildActionButton({
    required String label,
    required Gradient gradient,
    required Color borderColor,
    required Color textColor,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: gradient,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.45),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
