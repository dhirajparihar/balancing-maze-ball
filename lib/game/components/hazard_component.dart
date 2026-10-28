/// Hazard component — dangerous obstacle that causes failure on contact.
library;

import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../models/theme_data.dart';

class HazardComponent extends BodyComponent with ContactCallbacks {
  final Vector2 initialPosition;
  final double radius;
  final MazeThemeData theme;

  double _pulseTime = 0;

  HazardComponent({
    required this.initialPosition,
    required this.radius,
    required this.theme,
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.5,
      restitution: 0.5,
    );
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: initialPosition.clone(),
      userData: this,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
  }

  @override
  void render(Canvas canvas) {
    final pulse = 0.8 + sin(_pulseTime * 4) * 0.2;

    // Danger glow
    canvas.drawCircle(
      Offset.zero,
      radius * 1.5 * pulse,
      Paint()
        ..color = theme.hazardColor.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.25),
    );

    // Hazard body
    final gradient = RadialGradient(
      colors: [
        theme.hazardColor,
        Color.lerp(theme.hazardColor, Colors.black, 0.4)!,
      ],
    );

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset.zero, radius: radius),
        ),
    );

    // Warning pattern (X mark)
    final markPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 0.05
      ..strokeCap = StrokeCap.round;

    final markSize = radius * 0.4;
    canvas.drawLine(
      Offset(-markSize, -markSize),
      Offset(markSize, markSize),
      markPaint,
    );
    canvas.drawLine(
      Offset(markSize, -markSize),
      Offset(-markSize, markSize),
      markPaint,
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
