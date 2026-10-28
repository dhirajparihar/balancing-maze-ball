/// 3-Stars display widget — supports both HUD compact mode and animated victory dialog mode.
library;

import 'package:flutter/material.dart';

class StarsDisplay extends StatelessWidget {
  final int stars; // 0 to 3
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StarsDisplay({
    super.key,
    required this.stars,
    this.size = 18,
    this.activeColor = const Color(0xFF00E5FF),
    this.inactiveColor = const Color(0x4400E5FF),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isFilled = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            Icons.star,
            size: size,
            color: isFilled ? activeColor : inactiveColor,
            shadows: isFilled
                ? [
                    Shadow(
                      color: activeColor.withValues(alpha: 0.9),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

/// Animated 3-Stars for Victory / Level Complete dialog with sequential pop-in
class AnimatedVictoryStars extends StatefulWidget {
  final int stars;
  final double starSize;

  const AnimatedVictoryStars({
    super.key,
    required this.stars,
    this.starSize = 48,
  });

  @override
  State<AnimatedVictoryStars> createState() => _AnimatedVictoryStarsState();
}

class _AnimatedVictoryStarsState extends State<AnimatedVictoryStars>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _scaleAnimations = _controllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.elasticOut),
      );
    }).toList();

    _triggerAnimations();
  }

  void _triggerAnimations() async {
    for (int i = 0; i < widget.stars; i++) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (mounted) _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final earned = index < widget.stars;
        // Middle star is slightly elevated
        final yOffset = index == 1 ? -10.0 : 0.0;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ScaleTransition(
              scale: earned ? _scaleAnimations[index] : const AlwaysStoppedAnimation(1.0),
              child: Icon(
                Icons.star,
                size: widget.starSize,
                color: earned ? const Color(0xFFFFD700) : const Color(0x33FFFFFF),
                shadows: earned
                    ? [
                        const Shadow(
                          color: Color(0xFFFFAB00),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
