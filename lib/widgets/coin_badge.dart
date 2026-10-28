/// Glowing coin badge pill widget for header HUD and menus.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CoinBadge extends StatelessWidget {
  final int coins;
  final VoidCallback? onTap;

  const CoinBadge({
    super.key,
    required this.coins,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.25),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x33FFD54F),
              Color(0x11FFD54F),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFFFFF9C4), Color(0xFFFFB300), Color(0xFFFF6F00)],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFFB300),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '★',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatter.format(coins),
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Color(0xFFFFB300),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
