/// Balancing bar component — Forge2D kinematic rigid body platform.
/// Suspended across the board with left/right slider carriages.
/// Supports the rolling marble and physically pushes it upward as the player hoists the bar.
library;

import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../models/theme_data.dart';

class BalancingBarComponent extends BodyComponent {
  final double boardWidth;
  final MazeThemeData theme;
  final Vector2 initialPosition;

  double targetY;
  double targetAngle;

  BalancingBarComponent({
    required this.boardWidth,
    required this.theme,
    required this.initialPosition,
    this.targetAngle = 0.0,
  })  : targetY = initialPosition.y,
        super(priority: 10);

  @override
  Body createBody() {
    // Physical collider width fits cleanly between left/right boundary walls
    final halfWidth = boardWidth / 2 - 0.06;
    const halfHeight = 0.08;

    final shape = PolygonShape()
      ..setAsBox(
        halfWidth,
        halfHeight,
        Vector2.zero(),
        0.0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.2,
      restitution: 0.02,
    );

    final bodyDef = BodyDef(
      type: BodyType.kinematic,
      position: initialPosition.clone(),
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void updateTarget({required double y, required double angle}) {
    targetY = y;
    targetAngle = angle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) return;

    // Responsive kinematic tracking to target position & tilt angle
    final curPos = body.position;
    final curAngle = body.angle;

    final factor = min(1.0, 20.0 * dt);
    final newY = curPos.y + (targetY - curPos.y) * factor;
    final newAngle = curAngle + (targetAngle - curAngle) * factor;

    final safeDt = dt > 0 ? dt : 0.016;
    body.linearVelocity = Vector2(0, (newY - curPos.y) / safeDt);
    body.angularVelocity = (newAngle - curAngle) / safeDt;
    body.setTransform(Vector2(curPos.x, newY), newAngle);
  }

  @override
  void render(Canvas canvas) {
    // Visual rendering spans slightly wider to connect into side rail channels
    final visualHalfWidth = (boardWidth + 0.6) / 2;
    const barThickness = 0.16;
    final barRect = Rect.fromLTRB(-visualHalfWidth, -barThickness / 2, visualHalfWidth, barThickness / 2);

    // 1. Soft drop shadow under the bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        barRect.translate(0, 0.06),
        const Radius.circular(barThickness / 2),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.1),
    );

    // 2. Bar body with cylindrical metallic gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(theme.wallGlowColor, Colors.white, 0.6)!,
        theme.wallColor,
        Color.lerp(theme.wallColor, Colors.black, 0.5)!,
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(barThickness / 2)),
      Paint()..shader = gradient.createShader(barRect),
    );

    // 3. Neon glow core or candy cane / theme details
    if (theme.id == 'candy_dream') {
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndRadius(barRect, const Radius.circular(barThickness / 2)));
      final stripePaint = Paint()..color = Colors.red.withValues(alpha: 0.85)..strokeWidth = 0.12;
      for (double sx = -visualHalfWidth - 1.0; sx < visualHalfWidth + 1.0; sx += 0.3) {
        canvas.drawLine(Offset(sx, -barThickness), Offset(sx + 0.3, barThickness), stripePaint);
      }
      canvas.restore();
    } else {
      // Neon glow center line
      canvas.drawLine(
        Offset(-visualHalfWidth + 0.4, 0),
        Offset(visualHalfWidth - 0.4, 0),
        Paint()
          ..color = theme.wallGlowColor.withValues(alpha: 0.75)
          ..strokeWidth = 0.04
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.05),
      );
    }

    // 4. Left and Right Slider Carriages (mechanical collars on the side tracks)
    _renderCarriage(canvas, Offset(-visualHalfWidth + 0.15, 0));
    _renderCarriage(canvas, Offset(visualHalfWidth - 0.15, 0));
  }

  void _renderCarriage(Canvas canvas, Offset center) {
    const w = 0.22;
    const h = 0.38;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      const Radius.circular(0.06),
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(theme.boardFrameColor, Colors.white, 0.4)!,
        theme.boardFrameColor,
        Color.lerp(theme.boardFrameColor, Colors.black, 0.6)!,
      ],
    );

    canvas.drawRRect(
      rrect,
      Paint()..shader = gradient.createShader(rrect.outerRect),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = theme.wallGlowColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.025,
    );

    canvas.drawCircle(
      center,
      0.04,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
