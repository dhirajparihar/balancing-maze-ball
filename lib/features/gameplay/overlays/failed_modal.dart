/// Failed Modal Overlay — displays "FALL OUT!" with Revive, Try Again, and Main Menu.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../game/balancing_maze_game.dart';

class FailedModal extends StatelessWidget {
  final BalancingMazeGame game;
  final VoidCallback onRevive;
  final VoidCallback onTryAgain;
  final VoidCallback onMenu;

  const FailedModal({
    super.key,
    required this.game,
    required this.onRevive,
    required this.onTryAgain,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = game.currentTheme;
    final coins = game.gameService.playerData.coins;
    final canRevive = coins >= 50;
    final isTimeUp = game.remainingTime <= 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: Colors.black.withValues(alpha: 0.82),
              ),
            ),
          ),

          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFF140D17).withValues(alpha: 0.95),
                border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.7),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1744).withValues(alpha: 0.3),
                    blurRadius: 32,
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
                  // Fall Icon
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                      border: Border.all(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.7),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Icon(
                      isTimeUp ? Icons.timer_off_rounded : Icons.radio_button_checked_rounded,
                      color: const Color(0xFFFF5252),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header: "FALL OUT!" or "TIME UP!"
                  Text(
                    isTimeUp ? 'TIME UP!' : 'FALL OUT!',
                    style: TextStyle(
                      color: const Color(0xFFFF5252),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF1744).withValues(alpha: 0.9),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isTimeUp
                        ? 'Ran out of time before reaching the goal.'
                        : 'The marble fell through a hazard cutout.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFB0BEC5),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // REVIVE Button (Costs 50 coins)
                  GestureDetector(
                    onTap: canRevive
                        ? () async {
                            final success = await game.gameService.spendCoins(50);
                            if (success) {
                              HapticFeedback.mediumImpact();
                              onRevive();
                            }
                          }
                        : null,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: canRevive
                            ? const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                              )
                            : LinearGradient(
                                colors: [
                                  const Color(0xFF37474F).withValues(alpha: 0.5),
                                  const Color(0xFF263238).withValues(alpha: 0.5),
                                ],
                              ),
                        border: Border.all(
                          color: canRevive
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFF455A64),
                          width: 1.5,
                        ),
                        boxShadow: canRevive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: canRevive
                                ? const Color(0xFF3E2723)
                                : const Color(0xFF78909C),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'REVIVE MARBLE (50 🪙)',
                            style: TextStyle(
                              color: canRevive
                                  ? const Color(0xFF3E2723)
                                  : const Color(0xFF78909C),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // TRY AGAIN Button
                  _buildActionButton(
                    label: 'TRY AGAIN ↺',
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
                      onTryAgain();
                    },
                  ),
                  const SizedBox(height: 12),

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

  Widget _buildActionButton({
    required String label,
    required Gradient gradient,
    required Color borderColor,
    required Color textColor,
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
