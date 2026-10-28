/// 7-day streak daily reward dialog.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/game_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/neon_button.dart';

class DailyRewardsDialog extends StatefulWidget {
  final GameService gameService;

  const DailyRewardsDialog({super.key, required this.gameService});

  @override
  State<DailyRewardsDialog> createState() => _DailyRewardsDialogState();
}

class _DailyRewardsDialogState extends State<DailyRewardsDialog> {
  bool _claimed = false;

  final List<int> _rewards = [50, 75, 100, 125, 150, 200, 300];

  void _claim() async {
    HapticFeedback.heavyImpact();
    final reward = await widget.gameService.claimDailyReward();
    setState(() => _claimed = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed +$reward Daily Coins!'),
          backgroundColor: const Color(0xFF00E676),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = widget.gameService.playerData.dailyRewardDay; // 1-7
    final canClaim = widget.gameService.canClaimDailyReward() && !_claimed;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: GlassPanel(
          width: 340,
          borderColor: const Color(0xFFFF4081),
          backgroundColor: const Color(0xDD0D1B2A),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.card_giftcard, color: Color(0xFFFF4081), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'DAILY REWARDS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white54, size: 22),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              const Text(
                'Log in every day for greater coin bonuses!',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),

              const SizedBox(height: 20),

              // 7 Days Grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(7, (index) {
                  final dayNum = index + 1;
                  final reward = _rewards[index];
                  final isToday = dayNum == currentDay;
                  final isPast = dayNum < currentDay;

                  return Container(
                    width: 65,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isToday
                          ? const Color(0x33FF4081)
                          : (isPast ? Colors.white10 : Colors.black.withValues(alpha: 0.3)),
                      border: Border.all(
                        color: isToday
                            ? const Color(0xFFFF4081)
                            : (isPast ? const Color(0xFF00E676) : Colors.white12),
                        width: isToday ? 2.0 : 1.0,
                      ),
                      boxShadow: isToday
                          ? [
                              const BoxShadow(
                                color: Color(0x66FF4081),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DAY $dayNum',
                          style: TextStyle(
                            color: isToday ? const Color(0xFFFF4081) : Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          isPast ? Icons.check_circle : Icons.monetization_on,
                          color: isPast
                              ? const Color(0xFF00E676)
                              : (isToday ? const Color(0xFFFFD54F) : Colors.white38),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+$reward',
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Claim Button
              if (canClaim)
                NeonButton(
                  onPressed: _claim,
                  isAmberPlayButton: true,
                  child: const Text(
                    'CLAIM REWARD',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                )
              else
                NeonButton(
                  onPressed: () => Navigator.of(context).pop(),
                  primaryColor: const Color(0xFF546E7A),
                  child: const Text(
                    'COME BACK TOMORROW',
                    style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
