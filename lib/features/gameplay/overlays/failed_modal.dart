/// Game Over Modal — matches Reference Screen 8:
/// Vibrant "GAME OVER" header, DISTANCE, SCORE, "NEW RECORD!" banner,
/// BEST DISTANCE, RETRY, and HOME buttons.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FailedModal extends StatelessWidget {
  final int distance;
  final int score;
  final int bestDistance;
  final bool isNewRecord;
  final VoidCallback onRetry;
  final VoidCallback onHome;
  final VoidCallback? onLeaderboard;

  const FailedModal({
    super.key,
    required this.distance,
    required this.score,
    required this.bestDistance,
    required this.isNewRecord,
    required this.onRetry,
    required this.onHome,
    this.onLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final distStr = '${NumberFormat('#,###').format(distance)} m';
    final scoreStr = NumberFormat('#,###').format(score);
    final bestDistStr = '${NumberFormat('#,###').format(bestDistance)} m';

    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 310,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xFF091726).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF1744).withValues(alpha: 0.25),
                blurRadius: 28,
              ),
              const BoxShadow(
                color: Colors.black,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "GAME OVER" Header
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFF5252), Color(0xFFFF4081), Color(0xFF00E5FF)],
                ).createShader(bounds),
                child: const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // DISTANCE Label & Value
              const Text(
                'DISTANCE',
                style: TextStyle(
                  color: Color(0xFF90A4AE),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                distStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(color: Color(0xFF00E5FF), blurRadius: 16),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SCORE Label & Value
              const Text(
                'SCORE',
                style: TextStyle(
                  color: Color(0xFF90A4AE),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                scoreStr,
                style: const TextStyle(
                  color: Color(0xFF80DEEA),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 16),

              // "NEW RECORD!" Banner (if record broken)
              if (isNewRecord)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8F00), Color(0xFFFFB300), Color(0xFFFFC107)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8F00).withValues(alpha: 0.6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.black, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'NEW RECORD!',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // BEST DISTANCE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'BEST DISTANCE',
                    style: TextStyle(
                      color: Color(0xFF78909C),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bestDistStr,
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // RETRY Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF00B0FF), Color(0xFF0080FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                    label: const Text(
                      'RETRY',
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // HOME Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onHome,
                  icon: const Icon(Icons.home_rounded, color: Color(0xFF80DEEA), size: 22),
                  label: const Text(
                    'HOME',
                    style: TextStyle(
                      color: Color(0xFF80DEEA),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
