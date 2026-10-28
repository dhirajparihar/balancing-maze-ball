/// Pause Modal — matches Reference Screen 7:
/// Dark glassmorphic modal with DISTANCE, TIME, MULTIPLIER,
/// RESUME, RESTART, and MAIN MENU actions.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PauseModal extends StatelessWidget {
  final int distance;
  final double time;
  final int multiplier;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const PauseModal({
    super.key,
    required this.distance,
    required this.time,
    required this.multiplier,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final int minutes = (time / 60).floor();
    final int seconds = (time % 60).floor();
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final distStr = '${NumberFormat('#,###').format(distance)} m';

    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 310,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1B2C).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
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
              // "PAUSED" Title
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  shadows: [
                    Shadow(color: Color(0xFF00E5FF), blurRadius: 16),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Row List
              _buildStatRow('DISTANCE', distStr),
              const SizedBox(height: 12),
              _buildStatRow('TIME', timeStr),
              const SizedBox(height: 12),
              _buildStatRow('MULTIPLIER', 'x$multiplier', isHighlight: true),

              const SizedBox(height: 28),

              // RESUME Button (Glowing Cyan Pill)
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
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                    label: const Text(
                      'RESUME',
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

              // RESTART Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF80DEEA), size: 22),
                  label: const Text(
                    'RESTART',
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

              const SizedBox(height: 12),

              // MAIN MENU Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onMainMenu,
                  icon: const Icon(Icons.home_rounded, color: Color(0xFF80DEEA), size: 22),
                  label: const Text(
                    'MAIN MENU',
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

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF90A4AE),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFFFFD54F) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            shadows: isHighlight
                ? [const Shadow(color: Color(0xFFFFD54F), blurRadius: 10)]
                : null,
          ),
        ),
      ],
    );
  }
}
