/// Leaderboard screen — matches Reference Screen 9:
/// Header, GLOBAL vs FRIENDS tabs, ranked cards with medals & distances,
/// and pinned user rank card at the bottom.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/game_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final GameService gameService;

  const LeaderboardScreen({super.key, required this.gameService});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isGlobal = true;

  @override
  Widget build(BuildContext context) {
    final list = _isGlobal
        ? widget.gameService.getGlobalLeaderboard()
        : widget.gameService.getFriendsLeaderboard();

    final userEntry = list.firstWhere(
      (e) => e['isUser'] == true,
      orElse: () => {
        'rank': 23,
        'name': 'You',
        'distance': widget.gameService.playerData.bestDistance > 0
            ? widget.gameService.playerData.bestDistance
            : 2840,
        'isUser': true,
      },
    );

    final displayList = list.where((e) => e['isUser'] != true).toList();

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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'LEADERBOARD',
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

            const SizedBox(height: 16),

            // Segmented Tabs: GLOBAL | FRIENDS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1826),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isGlobal = true),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: _isGlobal
                              ? const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0080FF)])
                              : null,
                          boxShadow: _isGlobal
                              ? [const BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'GLOBAL',
                          style: TextStyle(
                            color: _isGlobal ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isGlobal = false),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: !_isGlobal
                              ? const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0080FF)])
                              : null,
                          boxShadow: !_isGlobal
                              ? [const BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'FRIENDS',
                          style: TextStyle(
                            color: !_isGlobal ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Top Ranked List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final item = displayList[index];
                  final rank = item['rank'] as int;
                  final name = item['name'] as String;
                  final distance = item['distance'] as int;
                  final distStr = '${NumberFormat('#,###').format(distance)} m';

                  Color badgeColor;
                  if (rank == 1) {
                    badgeColor = const Color(0xFFFFD700);
                  } else if (rank == 2) {
                    badgeColor = const Color(0xFFCFD8DC);
                  } else if (rank == 3) {
                    badgeColor = const Color(0xFFFF8A65);
                  } else {
                    badgeColor = const Color(0xFF1E3A54);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1826).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: rank <= 3
                            ? badgeColor.withValues(alpha: 0.6)
                            : const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Rank Circle
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: badgeColor,
                            boxShadow: rank <= 3
                                ? [BoxShadow(color: badgeColor.withValues(alpha: 0.5), blurRadius: 8)]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              color: rank <= 3 ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Name
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        // Distance
                        Text(
                          distStr,
                          style: TextStyle(
                            color: const Color(0xFF00E5FF),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.5), blurRadius: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pinned Bottom User Rank
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0C273C), Color(0xFF071928)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00E5FF),
                      boxShadow: [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10)],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${userEntry['rank']}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(userEntry['distance'])} m',
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(color: Color(0xFF00E5FF), blurRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
