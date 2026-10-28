/// Start Menu Overlay — matches Reference Image 1:
/// 3D extruded title "BALANCING MAZE", Best Score banner,
/// left vertical pill "SHOP", center glowing pill "PLAY ▶", right vertical pill "SETTINGS".
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../game/balancing_maze_game.dart';
import '../../../game/systems/level_definitions.dart';
import '../../../models/level_config.dart';

class StartMenuOverlay extends StatelessWidget {
  final BalancingMazeGame game;
  final VoidCallback onPlay;
  final void Function(BoardLevel level)? onPlayDailyChallenge;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenSettings;
  final VoidCallback? onOpenLevelMap;

  const StartMenuOverlay({
    super.key,
    required this.game,
    required this.onPlay,
    this.onPlayDailyChallenge,
    required this.onOpenShop,
    required this.onOpenSettings,
    this.onOpenLevelMap,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return Stack(
      children: [
        // 1. Top Section: 3D Extruded Title & Best Score Banner
        Positioned(
          top: topPadding + 28,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "BALANCING" in 3D cyan extruded metallic bevel
              _build3dExtrudedText(
                text: 'BALANCING',
                fontSize: 38,
                textColor: const Color(0xFFE0F7FA),
                bevelColor: const Color(0xFF00E5FF),
                shadowColor: const Color(0xFF006064),
              ),
              const SizedBox(height: 2),

              // "MAZE" in 3D warm gold/amber extruded metallic bevel
              _build3dExtrudedText(
                text: 'MAZE',
                fontSize: 46,
                textColor: const Color(0xFFFFF3E0),
                bevelColor: const Color(0xFFFFB74D),
                shadowColor: const Color(0xFFE65100),
              ),
              const SizedBox(height: 14),

              // ★ BEST SCORE Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 24, height: 1.5, color: const Color(0xFF00E5FF).withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                  const Icon(Icons.star_rounded, color: Color(0xFF00E5FF), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    game.gameService.playerData.bestScore > 0
                        ? 'BEST SCORE: ${game.gameService.playerData.bestScore}'
                        : 'READY TO BALANCE',
                    style: TextStyle(
                      color: const Color(0xFFE0F7FA).withValues(alpha: 0.95),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star_rounded, color: Color(0xFF00E5FF), size: 16),
                  const SizedBox(width: 8),
                  Container(width: 24, height: 1.5, color: const Color(0xFF00E5FF).withValues(alpha: 0.6)),
                ],
              ),
              const SizedBox(height: 12),

              // Current Level & Lesson Brief
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF0F1E33).withValues(alpha: 0.8),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'STAGE ${game.currentLevel.id}: ${game.currentLevel.modeName}',
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (game.currentLevel.lessonObjective.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        '🎯 ${game.currentLevel.lessonObjective}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFE0F7FA),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Interactive Daily Challenge Banner Card
              _buildDailyChallengeCard(context),

              // Campaign Map Selection Card
              if (onOpenLevelMap != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onOpenLevelMap!();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFF0F1E33).withValues(alpha: 0.85),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map_rounded, color: Color(0xFF00E5FF), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'CAMPAIGN MAP  (LEVELS 1–6)',
                          style: TextStyle(
                            color: const Color(0xFFE0F7FA),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00E5FF), size: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 2. Bottom Action Dock: Left vertical SHOP pill, Center PLAY CTA, Right SETTINGS pill
        Positioned(
          left: 18,
          right: 18,
          bottom: bottomPadding + 36,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Vertical Pill Button: SHOP
              _buildVerticalPillButton(
                icon: Icons.shopping_cart_outlined,
                label: 'SHOP',
                borderColor: const Color(0xFF00E5FF),
                glowColor: const Color(0xFF00E5FF),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onOpenShop();
                },
              ),

              // Center Primary CTA: Large Glowing PLAY ▶ Pill Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildPlayButton(),
                ),
              ),

              // Right Vertical Pill Button: SETTINGS
              _buildVerticalPillButton(
                icon: Icons.settings_outlined,
                label: 'SETTINGS',
                borderColor: const Color(0xFFFFB74D),
                glowColor: const Color(0xFFFFB74D),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onOpenSettings();
                },
              ),
            ],
          ),
        ),

        // 3. Version label at bottom right
        Positioned(
          right: 18,
          bottom: bottomPadding + 10,
          child: Text(
            'v1.0.2',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  /// 3D Extruded Bevelled Title Painter
  Widget _build3dExtrudedText({
    required String text,
    required double fontSize,
    required Color textColor,
    required Color bevelColor,
    required Color shadowColor,
  }) {
    return Stack(
      children: [
        // Extruded deep 3D drop shadow layers
        for (double offset = 6.0; offset > 0; offset -= 1.0)
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.5,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.5
                ..color = shadowColor,
            ),
          ),

        // Glowing outer bevel stroke
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.5,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0
              ..color = bevelColor,
            shadows: [
              Shadow(
                color: bevelColor.withValues(alpha: 0.9),
                blurRadius: 16,
              ),
            ],
          ),
        ),

        // Crisp solid face text
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.5,
          ),
        ),
      ],
    );
  }

  /// Left/Right Vertical Capsule Action Buttons (Rotated 90° Text)
  Widget _buildVerticalPillButton({
    required IconData icon,
    required String label,
    required Color borderColor,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.8),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              borderColor.withValues(alpha: 0.25),
              borderColor.withValues(alpha: 0.08),
              borderColor.withValues(alpha: 0.18),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 14),
                // Rotated Vertical Text (e.g. "SHOP" or "SETTINGS")
                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          color: glowColor.withValues(alpha: 0.9),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                // Icon at the bottom of the capsule
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Icon(
                    icon,
                    color: borderColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Large Glowing Pill Button "PLAY ▶"
  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPlay();
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: const Color(0xFFFFE082),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withValues(alpha: 0.85),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB74D),
              Color(0xFFFF8F00),
              Color(0xFFE65100),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PLAY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard(BuildContext context) {
    final challenge = DailyChallengeService.getTodaysChallenge();
    final mod = challenge.modifier;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPlayDailyChallenge?.call(challenge);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0F1E33).withValues(alpha: 0.88),
          border: Border.all(
            color: mod.badgeColor.withValues(alpha: 0.75),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: mod.badgeColor.withValues(alpha: 0.25),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mod.badgeColor.withValues(alpha: 0.2),
              ),
              child: Icon(Icons.flash_on_rounded, color: mod.badgeColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'DAILY CHALLENGE',
                        style: TextStyle(
                          color: mod.badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: mod.badgeColor.withValues(alpha: 0.25),
                        ),
                        child: Text(
                          mod.displayName,
                          style: TextStyle(
                            color: mod.badgeColor,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    challenge.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFCFD8DC),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: mod.badgeColor.withValues(alpha: 0.25),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
