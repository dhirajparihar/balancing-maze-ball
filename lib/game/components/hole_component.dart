/// Hole component — organic cutout hazard in the board (matching the reference art).
/// Renders a 3D bevelled hole cutout with deep-space opening and inner glow.
/// Features a Forge2D sensor body that triggers Fall Out if the marble rolls in.
library;

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../models/theme_data.dart';
import 'marble_component.dart';

typedef HoleFallCallback = void Function(Vector2 holeCenter);

class HoleComponent extends BodyComponent with ContactCallbacks {
  final Vector2 initialPosition;
  final double radius;
  final MazeThemeData theme;
  final HoleFallCallback onHoleFell;

  bool _hasFallen = false;

  HoleComponent({
    required this.initialPosition,
    required this.radius,
    required this.theme,
    required this.onHoleFell,
  }) : super(priority: -10);

  @override
  Body createBody() {
    // Sensor radius slightly smaller than visual radius so player has a small forgiveness margin
    final shape = CircleShape()..radius = radius * 0.75;
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
    if (_hasFallen) return;

    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;
    final otherBody =
        fixtureA.body.userData == this ? fixtureB.body : fixtureA.body;

    if (otherBody.userData is MarbleComponent) {
      _hasFallen = true;
      onHoleFell(body.position);
    }
  }

  @override
  void render(Canvas canvas) {
    // 1. Hole Interior (Deep Space darkness revealing background)
    final holePaint = Paint()
      ..color = const Color(0xFF040A12)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, holePaint);

    // 2. Inner Drop Shadow (simulating plate thickness & 2.5D depth)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.08;

    canvas.drawCircle(const Offset(0, -0.04), radius * 0.9, shadowPaint);

    // 3. Glowing Bevel Rim (Turquoise/Cyan neon rim matching Reference Images 1 & 2)
    final rimPaint = Paint()
      ..color = theme.wallGlowColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.06;

    final glowPaint = Paint()
      ..color = theme.wallGlowColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.14
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.08);

    canvas.drawCircle(Offset.zero, radius, glowPaint);
    canvas.drawCircle(Offset.zero, radius, rimPaint);

    // 4. Subtle inner highlight on top edge
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.03;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius - 0.02),
      3.14 * 0.8,
      3.14 * 1.4,
      false,
      highlightPaint,
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
