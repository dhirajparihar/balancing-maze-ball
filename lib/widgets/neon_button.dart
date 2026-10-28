/// Custom neon glowing buttons styled after the arcade reference art.
/// Includes horizontal pill buttons, vertical HUD pills (Shop/Settings), and standard action buttons.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NeonButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color primaryColor;
  final Color? glowColor;
  final double width;
  final double height;
  final double borderRadius;
  final bool isPill;
  final bool isAmberPlayButton;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.primaryColor = const Color(0xFF00E5FF),
    this.glowColor,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius = 28,
    this.isPill = true,
    this.isAmberPlayButton = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _animController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final glow = widget.glowColor ?? widget.primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value * (_isHovered ? 1.02 : 1.0),
            child: child,
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                // Outer vibrant glow
                BoxShadow(
                  color: glow.withValues(alpha: widget.isAmberPlayButton ? 0.6 : 0.35),
                  blurRadius: widget.isAmberPlayButton ? 24 : 16,
                  spreadRadius: widget.isAmberPlayButton ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
                // Deep contact shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
              // Gradient fill
              gradient: widget.isAmberPlayButton
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFB74D),
                        Color(0xFFFF9800),
                        Color(0xFFE65100),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.primaryColor.withValues(alpha: 0.35),
                        widget.primaryColor.withValues(alpha: 0.15),
                      ],
                    ),
              border: Border.all(
                color: widget.isAmberPlayButton
                    ? const Color(0xFFFFE0B2)
                    : widget.primaryColor.withValues(alpha: 0.8),
                width: widget.isAmberPlayButton ? 2.5 : 1.5,
              ),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Vertical pill button exactly matching the SHOP and SETTINGS buttons in Reference Image 1
class VerticalPillButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const VerticalPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<VerticalPillButton> createState() => _VerticalPillButtonState();
}

class _VerticalPillButtonState extends State<VerticalPillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          width: 52,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.7),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.color.withValues(alpha: 0.22),
                widget.color.withValues(alpha: 0.08),
                widget.color.withValues(alpha: 0.18),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rotated vertical label
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Center(
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              shadows: [
                                Shadow(
                                  color: widget.color.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Icon at bottom
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 22,
                        shadows: [
                          Shadow(
                            color: widget.color.withValues(alpha: 0.8),
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
        ),
      ),
    );
  }
}
