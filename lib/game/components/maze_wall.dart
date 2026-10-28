/// Maze wall component — static physics body for wall segments.
/// Renders with neon glow effect matching the theme.
library;

import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../models/theme_data.dart';

class MazeWallComponent extends BodyComponent {
  final Vector2? start;
  final Vector2? end;
  final double thickness;
  final MazeThemeData theme;
  final bool isHazard;
  final bool isCircle;
  final Vector2? circleCenter;
  final double? circleRadius;

  /// Create a line segment wall.
  MazeWallComponent({
    required Vector2 this.start,
    required Vector2 this.end,
    this.thickness = 0.25,
    required this.theme,
    this.isHazard = false,
  })  : isCircle = false,
        circleCenter = null,
        circleRadius = null;

  /// Create a circular obstacle wall.
  MazeWallComponent.circle({
    required Vector2 center,
    required double radius,
    required this.theme,
    this.isHazard = false,
  })  : isCircle = true,
        circleCenter = center,
        circleRadius = radius,
        start = null,
        end = null,
        thickness = 0;

  @override
  Body createBody() {
    if (isCircle) {
      return _createCircleBody();
    }
    return _createEdgeBody();
  }

  Body _createEdgeBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
      userData: this,
    );

    final body = world.createBody(bodyDef);

    // Create an edge shape between start and end
    final shape = EdgeShape()..set(start!, end!);
    body.createFixture(FixtureDef(
      shape,
      friction: 0.6,
      restitution: 0.2,
    ));

    return body;
  }

  Body _createCircleBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: circleCenter!.clone(),
      userData: this,
    );

    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = circleRadius!;
    body.createFixture(FixtureDef(
      shape,
      friction: 0.6,
      restitution: 0.2,
    ));

    return body;
  }

  @override
  void render(Canvas canvas) {
    final wallColor = isHazard ? theme.hazardColor : theme.wallColor;
    final glowColor = isHazard
        ? theme.hazardColor.withValues(alpha: 0.4)
        : theme.wallGlowColor.withValues(alpha: 0.3);

    if (isCircle) {
      _renderCircle(canvas, wallColor, glowColor);
    } else {
      _renderLine(canvas, wallColor, glowColor);
    }
  }

  void _renderLine(Canvas canvas, Color wallColor, Color glowColor) {
    final s = start!;
    final e = end!;

    // Glow effect (wider, blurred line behind)
    canvas.drawLine(
      Offset(s.x, s.y),
      Offset(e.x, e.y),
      Paint()
        ..color = glowColor
        ..strokeWidth = thickness + 0.3
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.2),
    );

    // Main wall line
    canvas.drawLine(
      Offset(s.x, s.y),
      Offset(e.x, e.y),
      Paint()
        ..color = wallColor
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round,
    );

    // Inner highlight
    canvas.drawLine(
      Offset(s.x, s.y),
      Offset(e.x, e.y),
      Paint()
        ..color = wallColor.withValues(alpha: 0.6)
        ..strokeWidth = thickness * 0.4
        ..strokeCap = StrokeCap.round,
    );

    // Top edge highlight (lighter)
    final dx = e.x - s.x;
    final dy = e.y - s.y;
    final len = sqrt(dx * dx + dy * dy);
    if (len > 0) {
      final nx = -dy / len * thickness * 0.3;
      final ny = dx / len * thickness * 0.3;

      canvas.drawLine(
        Offset(s.x + nx, s.y + ny),
        Offset(e.x + nx, e.y + ny),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..strokeWidth = 0.06
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _renderCircle(Canvas canvas, Color wallColor, Color glowColor) {
    // Glow
    canvas.drawCircle(
      Offset.zero,
      circleRadius! + 0.15,
      Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.2),
    );

    // Main circle
    final gradient = RadialGradient(
      colors: [
        wallColor.withValues(alpha: 0.9),
        wallColor,
        Color.lerp(wallColor, Colors.black, 0.3)!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    canvas.drawCircle(
      Offset.zero,
      circleRadius!,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset.zero, radius: circleRadius!),
        ),
    );

    // Highlight
    canvas.drawCircle(
      Offset(-circleRadius! * 0.2, -circleRadius! * 0.2),
      circleRadius! * 0.4,
      Paint()..color = Colors.white.withValues(alpha: 0.1),
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {
    // Skip debug rendering
  }
}
