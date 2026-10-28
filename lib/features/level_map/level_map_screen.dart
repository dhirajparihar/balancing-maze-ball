/// Level map / select screen — browses through the 30 handcrafted levels across worlds.
/// Shows stars earned, unlock status, high scores, and quick play.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/game_service.dart';
import '../../game/systems/level_definitions.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/stars_display.dart';
import '../gameplay/gameplay_screen.dart';

class LevelMapScreen extends StatefulWidget {
  final GameService gameService;

  const LevelMapScreen({super.key, required this.gameService});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  int _selectedWorld = 0;

  final List<Map<String, dynamic>> _worlds = [
    {
      'name': 'Campaign Worlds',
      'icon': Icons.public,
      'color': const Color(0xFF00E5FF),
      'levels': [1, 2, 3, 4, 5, 6],
      'isComingSoon': false,
    },
    {
      'name': 'Chapter 2: Orbit',
      'icon': Icons.flare,
      'color': const Color(0xFF448AFF),
      'levels': <int>[],
      'isComingSoon': true,
    },
    {
      'name': 'Chapter 3: Foundry',
      'icon': Icons.settings,
      'color': const Color(0xFFFFAB40),
      'levels': <int>[],
      'isComingSoon': true,
    },
  ];

  void _onLevelTap(int levelId) {
    if (!LevelDefinitions.hasLevel(levelId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This level is part of an upcoming expansion!'),
          backgroundColor: Color(0xFF00B0FF),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final isUnlocked = widget.gameService.playerData.isLevelUnlocked(levelId);
    if (!isUnlocked) {
      if (widget.gameService.playerData.vibrationEnabled) {
        HapticFeedback.vibrate();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete Level ${levelId - 1} to unlock!'),
          backgroundColor: const Color(0xFFE53935),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (widget.gameService.playerData.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => GameplayScreen(
          gameService: widget.gameService,
          levelId: levelId,
          startInMenu: false,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final worldData = _worlds[_selectedWorld];
    final worldColor = worldData['color'] as Color;
    final levelIds = worldData['levels'] as List<int>;
    final isComingSoon = worldData['isComingSoon'] as bool;

    return Scaffold(
      backgroundColor: const Color(0xFF08121E),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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

                  // Title & Stars count
                  Column(
                    children: [
                      const Text(
                        'LEVEL SELECT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.gameService.playerData.totalStars} / 18 Stars',
                            style: const TextStyle(
                              color: Color(0xFFFFE082),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Coin Badge
                  CoinBadge(coins: widget.gameService.playerData.coins),
                ],
              ),
            ),

            // World Tabs
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _worlds.length,
                itemBuilder: (context, index) {
                  final w = _worlds[index];
                  final isSelected = index == _selectedWorld;
                  final c = w['color'] as Color;

                  return GestureDetector(
                    onTap: () {
                      if (widget.gameService.playerData.vibrationEnabled) {
                        HapticFeedback.selectionClick();
                      }
                      setState(() => _selectedWorld = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? c.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                          color: isSelected ? c : Colors.white12,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: c.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(w['icon'] as IconData, size: 16, color: isSelected ? c : Colors.white54),
                          const SizedBox(width: 6),
                          Text(
                            w['name'] as String,
                            style: TextStyle(
                              color: isSelected ? c : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Level Cards Grid or Coming Soon Panel
            Expanded(
              child: isComingSoon
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: GlassPanel(
                          padding: const EdgeInsets.all(28),
                          borderRadius: 24,
                          borderColor: worldColor.withValues(alpha: 0.4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(worldData['icon'] as IconData, color: worldColor, size: 52),
                              const SizedBox(height: 14),
                              Text(
                                '${worldData['name']} Expansion',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Master all 6 Campaign levels to prepare for upcoming gravity shifts, magnetic pulleys, and cosmic mechanics.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: worldColor.withValues(alpha: 0.15),
                                  border: Border.all(color: worldColor, width: 1.0),
                                ),
                                child: Text(
                                  'COMING SOON',
                                  style: TextStyle(
                                    color: worldColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.90,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: levelIds.length,
                      itemBuilder: (context, index) {
                        final levelId = levelIds[index];
                        final levelData = LevelDefinitions.getLevel(levelId);
                        final isUnlocked = widget.gameService.playerData.isLevelUnlocked(levelId);
                        final stars = widget.gameService.playerData.getStarsForLevel(levelId);
                        final bestScore = widget.gameService.playerData.levelBestScores[levelId] ?? 0;

                        return GestureDetector(
                          onTap: () => _onLevelTap(levelId),
                          child: GlassPanel(
                            padding: const EdgeInsets.all(12),
                            borderRadius: 18,
                            borderColor: isUnlocked ? worldColor : Colors.white10,
                            backgroundColor: isUnlocked
                                ? worldColor.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.3),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Level Number Badge
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isUnlocked ? worldColor.withValues(alpha: 0.25) : Colors.white10,
                                            border: Border.all(
                                              color: isUnlocked ? worldColor : Colors.white24,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$levelId',
                                              style: TextStyle(
                                                color: isUnlocked ? Colors.white : Colors.white38,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Lock or Stars
                                        if (!isUnlocked)
                                          const Icon(Icons.lock, color: Colors.white38, size: 22)
                                        else
                                          StarsDisplay(
                                            stars: stars,
                                            size: 16,
                                            activeColor: const Color(0xFFFFD700),
                                            inactiveColor: Colors.white24,
                                          ),
                                      ],
                                    ),

                                    // Level Name, Lesson Objective & Par
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          levelData.modeName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isUnlocked ? Colors.white : Colors.white38,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (isUnlocked && levelData.lessonObjective.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            levelData.lessonObjective,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.72),
                                              fontSize: 9.5,
                                              height: 1.25,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          isUnlocked
                                              ? (bestScore > 0 ? 'Best: $bestScore (Par: ${levelData.parTimeSeconds.toInt()}s)' : 'Par: ${levelData.parTimeSeconds.toInt()}s')
                                              : 'Locked',
                                          style: TextStyle(
                                            color: isUnlocked ? worldColor.withValues(alpha: 0.85) : Colors.white24,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
