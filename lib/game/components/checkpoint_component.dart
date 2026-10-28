/// Checkpoint component — saves progress position when the marble touches it.
library;

import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../models/theme_data.dart';

typedef CheckpointActivatedCallback = void Function(int order);

class CheckpointComponent extends BodyComponent with ContactCallbacks {
  final Vector2 initialPosition;
  final int order;
  final MazeThemeData theme;
  final CheckpointActivatedCallback onActivated;

  bool _activated = false;
  double _animTime = 0;
  static const double _radius = 0.3;

  CheckpointComponent({
    required this.initialPosition,
    required this.order,
    required this.theme,
    required this.onActivated,
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = _radius;
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
    if (_activated) return;
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;
    final otherBody =
        fixtureA.body.userData == this ? fixtureB.body : fixtureA.body;

    if (otherBody.userData.runtimeType.toString() == 'MarbleComponent') {
      _activated = true;
      onActivated(order);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;
  }

  @override
  void render(Canvas canvas) {
    final color = _activated ? theme.exitColor : theme.accentColor;
    final alpha = _activated ? 0.9 : (0.5 + sin(_animTime * 2) * 0.3);

    // Glow
    canvas.drawCircle(
      Offset.zero,
      _radius * 1.4,
      Paint()
        ..color = color.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.15),
    );

    // Flag/marker
    canvas.drawCircle(
      Offset.zero,
      _radius,
      Paint()..color = color.withValues(alpha: alpha),
    );

    // Inner diamond shape
    final path = Path()
      ..moveTo(0, -_radius * 0.5)
      ..lineTo(_radius * 0.4, 0)
      ..lineTo(0, _radius * 0.5)
      ..lineTo(-_radius * 0.4, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: _activated ? 0.8 : 0.4),
    );

    // Checkmark if activated
    if (_activated) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 0.06
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(-_radius * 0.25, 0),
        Offset(-_radius * 0.05, _radius * 0.2),
        checkPaint,
      );
      canvas.drawLine(
        Offset(-_radius * 0.05, _radius * 0.2),
        Offset(_radius * 0.25, -_radius * 0.15),
        checkPaint,
      );
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
