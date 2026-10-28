/// Gameplay HUD Overlay — matches Reference Screens 3, 4, 5, 6:
/// Top glass pill with DISTANCE, TIME, MULTIPLIER, and PAUSE button.
/// Full-screen touch responders forwarding vertical drag movements on
/// left & right bar ends into BalanceRunnerGame.
/// Uses ValueNotifier for 60/120 FPS updates without rebuilding parent widget tree.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../game/balance_runner_game.dart';

class BalanceRunnerHudData {
  final int distance;
  final int score;
  final int multiplier;
  final double time;

  const BalanceRunnerHudData({
    this.distance = 0,
    this.score = 0,
    this.multiplier = 1,
    this.time = 0.0,
  });
}

class GameplayHudOverlay extends StatelessWidget {
  final BalanceRunnerGame game;
  final ValueNotifier<BalanceRunnerHudData> hudNotifier;
  final VoidCallback onPause;

  const GameplayHudOverlay({
    super.key,
    required this.game,
    required this.hudNotifier,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Transparent Gesture Detectors for Left & Right Lever Ends
        Positioned.fill(
          child: Row(
            children: [
              // Left half gesture area
              Expanded(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (e) => game.handlePointerDown(e.localPosition),
                  onPointerMove: (e) => game.handlePointerMove(e.localPosition),
                  onPointerUp: (e) => game.handlePointerUp(e.localPosition),
                  onPointerCancel: (e) => game.handlePointerUp(e.localPosition),
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Right half gesture area
              Expanded(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (e) => game.handlePointerDown(Offset(e.localPosition.dx + MediaQuery.of(context).size.width / 2, e.localPosition.dy)),
                  onPointerMove: (e) => game.handlePointerMove(Offset(e.localPosition.dx + MediaQuery.of(context).size.width / 2, e.localPosition.dy)),
                  onPointerUp: (e) => game.handlePointerUp(Offset(e.localPosition.dx + MediaQuery.of(context).size.width / 2, e.localPosition.dy)),
                  onPointerCancel: (e) => game.handlePointerUp(Offset(e.localPosition.dx + MediaQuery.of(context).size.width / 2, e.localPosition.dy)),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
        ),

        // 2. Top Glass Capsule HUD Bar (Rebuilds only on ValueListenable tick)
        Positioned(
          top: 14,
          left: 16,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: ValueListenableBuilder<BalanceRunnerHudData>(
              valueListenable: hudNotifier,
              builder: (context, hudData, _) {
                final int minutes = (hudData.time / 60).floor();
                final int seconds = (hudData.time % 60).floor();
                final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                final distStr = '${NumberFormat('#,###').format(hudData.distance)} m';

                return Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071422).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // DISTANCE
                      _buildHudColumn('DISTANCE', distStr),

                      // TIME
                      _buildHudColumn('TIME', timeStr),

                      // MULTIPLIER
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'MULTIPLIER',
                            style: TextStyle(
                              color: Color(0xFF78909C),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8F00).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFB300),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              'x${hudData.multiplier}',
                              style: const TextStyle(
                                color: Color(0xFFFFC107),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(color: Color(0xFFFFB300), blurRadius: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // PAUSE BUTTON
                      GestureDetector(
                        onTap: onPause,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.pause_rounded,
                            color: Color(0xFF00E5FF),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // 3. Subtle drag indicator hints at bottom ends
        Positioned(
          bottom: 24,
          left: 20,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.4,
              child: Column(
                children: const [
                  Icon(Icons.keyboard_arrow_up, color: Color(0xFF00E5FF), size: 24),
                  Text('DRAG', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold)),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFF00E5FF), size: 24),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 24,
          right: 20,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.4,
              child: Column(
                children: const [
                  Icon(Icons.keyboard_arrow_up, color: Color(0xFF00E5FF), size: 24),
                  Text('DRAG', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold)),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFF00E5FF), size: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHudColumn(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF78909C),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
