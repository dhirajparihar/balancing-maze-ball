/// Exit component — the level goal with sensor detection and glow.
library;

import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../models/theme_data.dart';
import 'marble_component.dart';

typedef ExitReachedCallback = void Function();

class ExitComponent extends BodyComponent with ContactCallbacks {
  final Vector2 initialPosition;
  final double radius;
  final MazeThemeData theme;
  final ExitReachedCallback onExitReached;

  double _pulseTime = 0;
  bool _reached = false;

  ExitComponent({
    required this.initialPosition,
    required this.radius,
    required this.theme,
    required this.onExitReached,
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape, isSensor: true);
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: initialPosition.clone(),
      userData: this,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (_reached) return;
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;
    final otherBody =
        fixtureA.body.userData == this ? fixtureB.body : fixtureA.body;

    if (otherBody.userData is MarbleComponent) {
      _reached = true;
      onExitReached();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
  }

  @override
  void render(Canvas canvas) {
    final pulse = 0.8 + sin(_pulseTime * 3) * 0.2;

    // Outer glow
    canvas.drawCircle(
      Offset.zero,
      radius * 1.5 * pulse,
      Paint()
        ..color = theme.exitColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3),
    );

    // Middle glow
    canvas.drawCircle(
      Offset.zero,
      radius * 1.2 * pulse,
      Paint()
        ..color = theme.exitColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.15),
    );

    // Exit circle
    final gradient = RadialGradient(
      colors: [
        theme.exitColor.withValues(alpha: 0.9),
        theme.exitColor.withValues(alpha: 0.5),
        theme.exitColor.withValues(alpha: 0.1),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset.zero, radius: radius),
        ),
    );

    // Arrow indicator
    final arrowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * pulse)
      ..strokeWidth = 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arrowSize = radius * 0.4;
    canvas.drawLine(
      Offset(-arrowSize, arrowSize * 0.5),
      Offset(0, -arrowSize * 0.5),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(arrowSize, arrowSize * 0.5),
      Offset(0, -arrowSize * 0.5),
      arrowPaint,
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
