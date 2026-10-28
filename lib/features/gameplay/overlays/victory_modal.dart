/// Victory Modal Overlay — 3-star victory dialog with score, coins, time bonus, and Next Level / Replay.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../game/balancing_maze_game.dart';
import '../../../game/systems/level_definitions.dart';

class VictoryModal extends StatelessWidget {
  final BalancingMazeGame game;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  const VictoryModal({
    super.key,
    required this.game,
    required this.onNextLevel,
    required this.onReplay,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = game.currentTheme;
    final scoreStr = NumberFormat('#,###').format(game.score);
    final elapsedSec = game.elapsedTime.round();
    final m = elapsedSec ~/ 60;
    final s = elapsedSec % 60;
    final timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    final hasNextLevel = game.currentLevel.id < LevelDefinitions.allLevels.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),

          Center(
            child: Container(
              width: 330,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: const Color(0xFF0D1626).withValues(alpha: 0.95),
                border: Border.all(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.7),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                    blurRadius: 36,
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
                  // 3 Stars Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isEarned = index < game.stars;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Icon(
                          Icons.star_rounded,
                          size: index == 1 ? 48 : 38,
                          color: isEarned
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFF37474F),
                          shadows: isEarned
                              ? [
                                  const Shadow(
                                    color: Color(0xFFFF8F00),
                                    blurRadius: 16,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Header: "VICTORY!"
                  Text(
                    'VICTORY!',
                    style: TextStyle(
                      color: const Color(0xFFFFD54F),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.5,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.9),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${game.currentLevel.id} Cleared',
                    style: const TextStyle(
                      color: Color(0xFF90A4AE),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Stats Panel
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFF131F33),
                      border: Border.all(
                        color: theme.rimColor.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('SCORE', scoreStr, const Color(0xFF00E5FF)),
                        const Divider(color: Color(0xFF1E2D4A), height: 14),
                        _buildStatRow('CUMULATIVE TIME', timeStr, const Color(0xFFECEFF1)),
                        const Divider(color: Color(0xFF1E2D4A), height: 14),
                        _buildStatRow(
                          'PAR TIME TARGET',
                          '${game.currentLevel.parTimeSeconds.toInt()}s (${game.elapsedTime <= game.currentLevel.parTimeSeconds ? 'BEATEN ★' : 'MISSED'})',
                          game.elapsedTime <= game.currentLevel.parTimeSeconds ? const Color(0xFF00E676) : const Color(0xFFFF8A80),
                        ),
                        const Divider(color: Color(0xFF1E2D4A), height: 14),
                        _buildStatRow(
                          'ATTEMPTS / FALLS',
                          game.attempts == 1 ? '1 (FLAWLESS ★)' : '${game.attempts} Attempts',
                          game.attempts == 1 ? const Color(0xFF00E676) : const Color(0xFFFFB74D),
                        ),
                        const Divider(color: Color(0xFF1E2D4A), height: 14),
                        _buildStatRow(
                          'REWARD',
                          game.currentLevel.coinMultiplier > 1.0
                              ? '+${(15 * game.currentLevel.coinMultiplier).round() + game.stars * 10} 🪙 (${game.currentLevel.coinMultiplier}X)'
                              : '+${15 + game.stars * 10} 🪙',
                          const Color(0xFFFFD54F),
                        ),
                      ],
                    ),
                  ),
                  if (game.wallBounces == 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF00E676).withValues(alpha: 0.15),
                        border: Border.all(color: const Color(0xFF00E676), width: 1.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: Color(0xFF00E676), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'ZERO-WALL-BOUNCE MASTERY ★',
                            style: TextStyle(
                              color: Color(0xFF69F0AE),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // NEXT LEVEL Button or All Levels Mastered Banner
                  if (hasNextLevel)
                    _buildActionButton(
                      label: 'NEXT LEVEL ▶',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                      ),
                      borderColor: const Color(0xFFFFD54F),
                      textColor: const Color(0xFF3E2723),
                      isPrimary: true,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onNextLevel();
                      },
                    )
                  else if (game.currentLevel.id == LevelDefinitions.allLevels.length)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.12),
                        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD54F), size: 30),
                          SizedBox(height: 6),
                          Text(
                            'ALL 6 CAMPAIGN LEVELS MASTERED!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Try the Daily Challenge or beat your personal best ghosts!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // REPLAY Button
                  _buildActionButton(
                    label: 'REPLAY ↺',
                    gradient: LinearGradient(
                      colors: [
                        theme.rimColor.withValues(alpha: 0.25),
                        theme.rimGlowColor.withValues(alpha: 0.35),
                      ],
                    ),
                    borderColor: theme.rimColor.withValues(alpha: 0.6),
                    textColor: const Color(0xFFECEFF1),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onReplay();
                    },
                  ),

                  const SizedBox(height: 10),

                  // MAIN MENU
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onMenu();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(
                        'MAIN MENU',
                        style: TextStyle(
                          color: Color(0xFF90A4AE),
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

  Widget _buildStatRow(String label, String value, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF78909C),
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ],
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
