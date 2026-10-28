/// Coin component — collectible with spinning animation and sensor body.
library;

import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../models/theme_data.dart';

typedef CoinCollectedCallback = void Function(String coinId, int value);

class CoinComponent extends BodyComponent with ContactCallbacks {
  final String coinId;
  final Vector2 initialPosition;
  final int value;
  final MazeThemeData theme;
  final CoinCollectedCallback onCollected;

  bool _collected = false;
  double _spinAngle = 0;
  double _floatOffset = 0;
  static const double _coinRadius = 0.2;

  CoinComponent({
    required this.coinId,
    required this.initialPosition,
    required this.value,
    required this.theme,
    required this.onCollected,
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = _coinRadius;

    final fixtureDef = FixtureDef(
      shape,
      isSensor: true, // sensor = triggers contact but no collision
    );

    final bodyDef = BodyDef(
      type: BodyType.static,
      position: initialPosition.clone(),
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (_collected) return;
    // Check if the other body is the marble
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;
    final otherBody =
        fixtureA.body.userData == this ? fixtureB.body : fixtureA.body;

    if (otherBody.userData.runtimeType.toString() == 'MarbleComponent') {
      _collected = true;
      onCollected(coinId, value);
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spinAngle += dt * 3.0; // spin speed
    _floatOffset = sin(_spinAngle * 0.8) * 0.05; // gentle float
  }

  @override
  void render(Canvas canvas) {
    if (_collected) return;

    canvas.save();
    canvas.translate(0, _floatOffset);

    // Glow
    canvas.drawCircle(
      Offset.zero,
      _coinRadius + 0.1,
      Paint()
        ..color = theme.coinColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.15),
    );

    // Coin body with "3D spin" effect
    final scaleX = cos(_spinAngle).abs().clamp(0.3, 1.0);

    canvas.scale(scaleX, 1.0);

    // Coin gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [
        Colors.white.withValues(alpha: 0.9),
        theme.coinColor,
        Color.lerp(theme.coinColor, Colors.brown, 0.3)!,
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    canvas.drawCircle(
      Offset.zero,
      _coinRadius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset.zero, radius: _coinRadius),
        ),
    );

    // Inner ring
    canvas.drawCircle(
      Offset.zero,
      _coinRadius * 0.7,
      Paint()
        ..color = theme.coinColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.02,
    );

    // Dollar sign or star
    final textPainter = TextPainter(
      text: TextSpan(
        text: '★',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: _coinRadius * 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
