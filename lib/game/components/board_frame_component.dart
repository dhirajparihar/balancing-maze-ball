/// Board frame component — renders the vertical mechanical labyrinth frame,
/// side rails, pulleys at the top, tension cables, and organic cutout holes.
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/level_data.dart';
import '../../models/theme_data.dart';

class BoardFrameComponent extends PositionComponent {
  final double boardWidth;
  final double boardHeight;
  final MazeThemeData theme;
  final List<CircleObstacle> holes;

  BoardFrameComponent({
    required this.boardWidth,
    required this.boardHeight,
    required this.theme,
    this.holes = const [],
  }) : super(priority: -50);

  @override
  void render(Canvas canvas) {
    // 1. Board Backing Plate with 2.5D bevel
    final boardRect = Rect.fromLTWH(0, 0, boardWidth, boardHeight);

    // Drop shadow under board plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect.inflate(0.12),
        const Radius.circular(0.35),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.35),
    );

    // Board plate fill (Teal/Turquoise Metal from Reference Image 1 & 2)
    final plateGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(theme.wallColor, const Color(0xFF1E6573), 0.5)!,
        theme.wallColor,
        Color.lerp(theme.wallColor, Colors.black, 0.4)!,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(0.25)),
      Paint()..shader = plateGradient.createShader(boardRect),
    );

    // Inner board bevel rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.deflate(0.05), const Radius.circular(0.2)),
      Paint()
        ..color = theme.wallGlowColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.03,
    );

    // 2. Render Cutout Holes (Revealing deep space behind the board)
    for (final hole in holes) {
      final center = Offset(hole.center.dx, hole.center.dy);
      final r = hole.radius;

      // Dark hole interior
      canvas.drawCircle(
        center,
        r,
        Paint()..color = const Color(0xFF040A12),
      );

      // 3D Inner drop shadow (depth into the board plate)
      canvas.drawCircle(
        center.translate(0, -0.04),
        r * 0.9,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.07,
      );

      // Glowing bevel rim
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = theme.wallGlowColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.045,
      );
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = theme.wallGlowColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.06),
      );
    }

    // 3. Vertical Mechanical Side Rails (Left & Right)
    const railWidth = 0.55;
    final leftRailRect = Rect.fromLTWH(-railWidth, -0.3, railWidth, boardHeight + 0.6);
    final rightRailRect = Rect.fromLTWH(boardWidth, -0.3, railWidth, boardHeight + 0.6);

    _renderRail(canvas, leftRailRect, isLeft: true);
    _renderRail(canvas, rightRailRect, isLeft: false);

    // 4. Top Crossbeam with Pulleys (At the TOP of the board: Y = 0)
    _renderCrossbeam(
      canvas,
      Rect.fromLTWH(-railWidth * 1.1, -0.45, boardWidth + railWidth * 2.2, 0.45),
      isTop: true,
    );

    // Bottom Crossbeam (At the BOTTOM of the board: Y = boardHeight)
    _renderCrossbeam(
      canvas,
      Rect.fromLTWH(-railWidth * 1.1, boardHeight, boardWidth + railWidth * 2.2, 0.45),
      isTop: false,
    );

    // Pulley Wheels at the TOP of the side rails
    _renderPulley(canvas, Offset(-railWidth / 2, -0.2));
    _renderPulley(canvas, Offset(boardWidth + railWidth / 2, -0.2));

    // Tension Cables running down the rails
    final cablePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 0.035
      ..style = PaintingStyle.stroke;

    final cableGlow = Paint()
      ..color = theme.wallGlowColor.withValues(alpha: 0.4)
      ..strokeWidth = 0.08
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.05);

    // Left cable hanging down from top pulley
    canvas.drawLine(Offset(-railWidth / 2, -0.2), Offset(-railWidth / 2, boardHeight), cableGlow);
    canvas.drawLine(Offset(-railWidth / 2, -0.2), Offset(-railWidth / 2, boardHeight), cablePaint);

    // Right cable hanging down from top pulley
    canvas.drawLine(Offset(boardWidth + railWidth / 2, -0.2), Offset(boardWidth + railWidth / 2, boardHeight), cableGlow);
    canvas.drawLine(Offset(boardWidth + railWidth / 2, -0.2), Offset(boardWidth + railWidth / 2, boardHeight), cablePaint);
  }

  void _renderRail(Canvas canvas, Rect rect, {required bool isLeft}) {
    // Rail casing
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isLeft
          ? [
              Color.lerp(theme.boardFrameColor, Colors.white, 0.25)!,
              theme.boardFrameColor,
              Color.lerp(theme.boardFrameColor, Colors.black, 0.5)!,
            ]
          : [
              Color.lerp(theme.boardFrameColor, Colors.black, 0.5)!,
              theme.boardFrameColor,
              Color.lerp(theme.boardFrameColor, Colors.white, 0.25)!,
            ],
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(0.08)),
      Paint()..shader = gradient.createShader(rect),
    );

    // Inner guide slot channel (where the carriage slides)
    final slotX = rect.center.dx;
    final slotRect = Rect.fromCenter(
      center: Offset(slotX, rect.center.dy),
      width: 0.1,
      height: rect.height - 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(slotRect, const Radius.circular(0.04)),
      Paint()..color = Colors.black.withValues(alpha: 0.75),
    );

    // Glowing neon line on rail edge
    canvas.drawLine(
      Offset(isLeft ? rect.right : rect.left, rect.top + 0.3),
      Offset(isLeft ? rect.right : rect.left, rect.bottom - 0.3),
      Paint()
        ..color = theme.wallGlowColor.withValues(alpha: 0.6)
        ..strokeWidth = 0.035
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.05),
    );
  }

  void _renderCrossbeam(Canvas canvas, Rect rect, {required bool isTop}) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(theme.boardFrameColor, Colors.white, 0.3)!,
        theme.boardFrameColor,
        Color.lerp(theme.boardFrameColor, Colors.black, 0.6)!,
      ],
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(0.1)),
      Paint()..shader = gradient.createShader(rect),
    );

    _renderBolt(canvas, Offset(rect.left + 0.3, rect.center.dy));
    _renderBolt(canvas, Offset(rect.right - 0.3, rect.center.dy));
  }

  void _renderPulley(Canvas canvas, Offset center) {
    const radius = 0.2;
    canvas.drawCircle(
      center,
      radius + 0.05,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    final gradient = RadialGradient(
      colors: [
        Color.lerp(theme.boardFrameColor, Colors.white, 0.4)!,
        theme.boardFrameColor,
        Color.lerp(theme.boardFrameColor, Colors.black, 0.7)!,
      ],
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Center pin
    canvas.drawCircle(center, 0.06, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  void _renderBolt(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 0.07, Paint()..color = Colors.black.withValues(alpha: 0.7));
    canvas.drawCircle(center, 0.05, Paint()..color = Colors.white.withValues(alpha: 0.8));
    canvas.drawCircle(center, 0.02, Paint()..color = Colors.black);
  }
}
