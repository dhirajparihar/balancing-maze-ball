/// Daily Challenge screen — matches Reference Screen 11:
/// Countdown timer until refresh, "Same track for everyone today!",
/// procedural track preview, top players today, and "PLAY CHALLENGE" action.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/game_service.dart';
import '../gameplay/gameplay_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  final GameService gameService;

  const DailyChallengeScreen({super.key, required this.gameService});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late Timer _timer;
  late Duration _timeUntilMidnight;

  @override
  void initState() {
    super.initState();
    _updateTimeUntilMidnight();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeUntilMidnight();
      setState(() {});
    });
  }

  void _updateTimeUntilMidnight() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _timeUntilMidnight = tomorrow.difference(now);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onPlayDailyChallenge() {
    // Generate daily seed e.g. 20261028
    final now = DateTime.now();
    final dailySeed = now.year * 10000 + now.month * 100 + now.day;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => GameplayScreen(
          gameService: widget.gameService,
          seed: dailySeed,
          isDailyChallenge: true,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hours = _timeUntilMidnight.inHours.toString().padLeft(2, '0');
    final minutes = (_timeUntilMidnight.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeUntilMidnight.inSeconds % 60).toString().padLeft(2, '0');
    final countdownStr = '$hours:$minutes:$seconds';

    final topToday = widget.gameService.getDailyChallengeLeaderboard();

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
                      'DAILY CHALLENGE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
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

            const SizedBox(height: 10),

            // Timer & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFFFFD54F), size: 18),
                const SizedBox(width: 6),
                Text(
                  countdownStr,
                  style: const TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(color: Color(0xFFFFD54F), blurRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Same track for everyone today!',
              style: TextStyle(
                color: Color(0xFF80DEEA),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            // Mini Track Preview
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFF091624),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: _DailyTrackPreviewPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Top Players Today Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TOP PLAYERS TODAY',
                  style: TextStyle(
                    color: const Color(0xFF5CF3FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.8), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Ranked List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: topToday.length,
                itemBuilder: (context, index) {
                  final item = topToday[index];
                  final rank = item['rank'] as int;
                  final name = item['name'] as String;
                  final distance = item['distance'] as int;
                  final isUser = item['isUser'] == true;

                  Color rankColor;
                  if (rank == 1) {
                    rankColor = const Color(0xFFFFD700);
                  } else if (rank == 2) {
                    rankColor = const Color(0xFFCFD8DC);
                  } else if (rank == 3) {
                    rankColor = const Color(0xFFFF8A65);
                  } else {
                    rankColor = const Color(0xFF1E3A54);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF0C2B42)
                          : const Color(0xFF0A1826).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUser
                            ? const Color(0xFF00E5FF)
                            : const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rankColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              color: rank <= 3 ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: isUser ? const Color(0xFF00E5FF) : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '${NumberFormat('#,###').format(distance)} m',
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // "PLAY CHALLENGE" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF00B0FF), Color(0xFF0080FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _onPlayDailyChallenge,
                    icon: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                    label: const Text(
                      'PLAY CHALLENGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTrackPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Side Rails
    final railPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.3)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(24, 0), Offset(24, size.height), railPaint);
    canvas.drawLine(Offset(size.width - 24, 0), Offset(size.width - 24, size.height), railPaint);

    // Track Organic Cutout Holes
    final holePaint = Paint()..color = const Color(0xFF040B13);
    final holeRim = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final holes = [
      RRect.fromRectAndRadius(const Rect.fromLTWH(34, 15, 60, 35), const Radius.circular(12)),
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 94, 25, 55, 40), const Radius.circular(12)),
      RRect.fromRectAndRadius(const Rect.fromLTWH(44, 75, 50, 35), const Radius.circular(12)),
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 100, 80, 60, 35), const Radius.circular(12)),
    ];

    for (final h in holes) {
      canvas.drawRRect(h, holePaint);
      canvas.drawRRect(h, holeRim);
    }

    // Rotating Cog Hazard in Center
    canvas.save();
    canvas.translate(cx, 55);
    final gearPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(Offset.zero, 14, gearPaint);
    final coreGradient = const RadialGradient(
      colors: [Color(0xFFFFF176), Color(0xFFFF9100), Color(0xFFFF3D00)],
    );
    canvas.drawCircle(
      Offset.zero,
      9,
      Paint()..shader = coreGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: 9)),
    );
    canvas.restore();

    // Balance Bar at bottom of preview
    final barRect = Rect.fromCenter(center: Offset(cx, size.height - 18), width: 140, height: 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF00E5FF),
    );
    // Ball
    canvas.drawCircle(Offset(cx - 15, size.height - 25), 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
