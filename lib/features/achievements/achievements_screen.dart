/// Achievements screen — track progression milestones and claim coin rewards.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/game_service.dart';
import '../../models/achievement.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/neon_button.dart';

class AchievementsScreen extends StatefulWidget {
  final GameService gameService;

  const AchievementsScreen({super.key, required this.gameService});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  void _claimReward(Achievement achievement) async {
    HapticFeedback.heavyImpact();
    final coins = await widget.gameService.claimAchievementReward(achievement.id);
    if (coins > 0) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Claimed $coins Coins for "${achievement.name}"!'),
            backgroundColor: const Color(0xFF00E676),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievements = Achievements.all;

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
                  const Text(
                    'ACHIEVEMENTS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  CoinBadge(coins: widget.gameService.playerData.coins),
                ],
              ),
            ),

            // Achievements List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final item = achievements[index];
                  final isCompleted = widget.gameService.playerData.achievementsCompleted[item.id] == true;
                  final isClaimed = widget.gameService.playerData.achievementsClaimed[item.id] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: GlassPanel(
                      borderColor: isCompleted ? const Color(0xFFFFD54F) : Colors.white12,
                      backgroundColor: isCompleted ? const Color(0x22FFD54F) : Colors.black.withValues(alpha: 0.3),
                      child: Row(
                        children: [
                          // Trophy Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted ? const Color(0x33FFD54F) : Colors.white10,
                              border: Border.all(
                                color: isCompleted ? const Color(0xFFFFD54F) : Colors.white24,
                              ),
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: isCompleted ? const Color(0xFFFFD54F) : Colors.white38,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Text details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    color: isCompleted ? Colors.white : Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '+${item.rewardCoins} Coins',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD54F),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action button or Claimed status
                          if (isClaimed)
                            const Text(
                              'CLAIMED',
                              style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12),
                            )
                          else if (isCompleted)
                            SizedBox(
                              width: 85,
                              height: 36,
                              child: NeonButton(
                                height: 36,
                                onPressed: () => _claimReward(item),
                                primaryColor: const Color(0xFFFFD54F),
                                child: const Text(
                                  'CLAIM',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                                ),
                              ),
                            )
                          else
                            const Icon(Icons.lock, color: Colors.white24, size: 20),
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
