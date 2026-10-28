/// Dual vertical balancing slider widget (L and R controls).
/// Exactly matches the mechanical frosted glass sliders in the reference images.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BalanceSlider extends StatefulWidget {
  final String label; // "L" or "R"
  final double value; // 0.0 (bottom) to 1.0 (top)
  final ValueChanged<double> onChanged;
  final Color primaryColor;
  final Color accentColor;
  final double height;
  final double width;

  const BalanceSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.primaryColor = const Color(0xFF00E5FF),
    this.accentColor = const Color(0xFFFFB74D),
    this.height = 260,
    this.width = 54,
  });

  @override
  State<BalanceSlider> createState() => _BalanceSliderState();
}

class _BalanceSliderState extends State<BalanceSlider> {
  bool _isDragging = false;

  void _handleDrag(DragUpdateDetails details, double trackHeight) {
    // Top of track is 1.0, bottom of track is 0.0
    final localY = details.localPosition.dy.clamp(0.0, trackHeight);
    final normalized = (1.0 - (localY / trackHeight)).clamp(0.0, 1.0);
    widget.onChanged(normalized);
  }

  void _handleTapDown(TapDownDetails details, double trackHeight) {
    setState(() => _isDragging = true);
    HapticFeedback.selectionClick();
    final localY = details.localPosition.dy.clamp(0.0, trackHeight);
    final normalized = (1.0 - (localY / trackHeight)).clamp(0.0, 1.0);
    widget.onChanged(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.width / 2),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.primaryColor.withValues(alpha: 0.2),
            widget.primaryColor.withValues(alpha: 0.08),
            widget.primaryColor.withValues(alpha: 0.16),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.width / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // "L" or "R" header
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: widget.accentColor.withValues(alpha: 0.9),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Interactive Slider Track
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final h = constraints.maxHeight;
                    // knob position (0 = bottom, 1 = top)
                    final knobY = (1.0 - widget.value.clamp(0.0, 1.0)) * (h - 32);

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _handleTapDown(d, h),
                      onTapUp: (_) => setState(() => _isDragging = false),
                      onTapCancel: () => setState(() => _isDragging = false),
                      onVerticalDragStart: (_) => setState(() => _isDragging = true),
                      onVerticalDragUpdate: (d) => _handleDrag(d, h),
                      onVerticalDragEnd: (_) => setState(() => _isDragging = false),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Center vertical groove / track
                          Positioned(
                            top: 14,
                            bottom: 14,
                            child: Container(
                              width: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.5),
                                color: Colors.black.withValues(alpha: 0.6),
                                border: Border.all(
                                  color: widget.accentColor.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                            ),
                          ),

                          // Active filled track
                          Positioned(
                            top: knobY + 16,
                            bottom: 14,
                            child: Container(
                              width: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    widget.accentColor,
                                    widget.accentColor.withValues(alpha: 0.3),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.accentColor.withValues(alpha: 0.7),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Glowing Knob / Handle
                          Positioned(
                            top: knobY,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 60),
                              width: _isDragging ? 32 : 28,
                              height: _isDragging ? 32 : 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white,
                                    widget.accentColor,
                                    Color.lerp(widget.accentColor, Colors.black, 0.4)!,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.accentColor.withValues(alpha: 0.9),
                                    blurRadius: _isDragging ? 16 : 10,
                                    spreadRadius: _isDragging ? 2 : 1,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
