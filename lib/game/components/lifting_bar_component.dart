/// Lifting bar component — Forge2D kinematic rigid body platform.
/// Spans horizontally between Left rail (x = 6.0) and Right rail (x = 34.0).
/// Spring-damped velocity driving (NO setTransform teleportation during gameplay),
/// anti-catapult velocity clamping, and mechanical tilt limiter.
library;

import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/maze_theme_config.dart';

class LiftingBarComponent extends BodyComponent {
  final double railLeftX;
  final double railRightX;
  final double barThickness;
  final MazeThemeConfig theme;
  final Vector2 initialMidpoint;

  // Independent left and right target Y coordinates
  double targetLeftY;
  double targetRightY;

  // Current interpolated carriage Y positions
  double currentLeftY;
  double currentRightY;

  // Maximum tilt differential (approx ±18 degrees)
  static const double maxTiltDifferential = 9.0;
  // Anti-catapult maximum vertical speeds: calibrated for heavy mechanical cable tension
  static const double maxUpwardSpeed = 9.0;
  static const double maxDownwardSpeed = 10.0;
  // Maximum angular velocity clamp (rad/s) — prevents rotational catapulting
  static const double maxAngularVelocity = 2.5;
  // Maximum linear acceleration clamp (units/s²) — prevents sudden multi-touch thrusts
  static const double maxLinearAcceleration = 30.0;
  // Follow speed for spring-damped velocity integration
  static const double followSpeed = 12.0;

  final bool Function()? isVibrationEnabled;

  bool isOverTilted = false;
  bool _previousOverTilted = false;

  LiftingBarComponent({
    required this.railLeftX,
    required this.railRightX,
    this.barThickness = 1.8,
    required this.theme,
    required this.initialMidpoint,
    this.isVibrationEnabled,
  })  : targetLeftY = initialMidpoint.y,
        targetRightY = initialMidpoint.y,
        currentLeftY = initialMidpoint.y,
        currentRightY = initialMidpoint.y,
        super(priority: 20);

  double get spanWidth => railRightX - railLeftX;
  double get centerX => (railLeftX + railRightX) / 2.0;

  /// Vertical velocity of the bar surface at a given world X coordinate
  double verticalVelocityAtX(double worldX) {
    if (!isLoaded) return 0.0;
    final offsetX = worldX - centerX;
    return body.linearVelocity.y + (body.angularVelocity * offsetX);
  }

  @override
  Body createBody() {
    final halfWidth = spanWidth / 2.0 - 0.15;
    // Fixture thickness: 0.9 units halfHeight (total 1.8 units box thickness)
    // Ensures marble cannot tunnel through on steep tilts
    const halfHeight = 0.9;

    final shape = PolygonShape()
      ..setAsBox(
        halfWidth,
        halfHeight,
        Vector2.zero(),
        0.0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.50, // Firm physical grip
      restitution: 0.0, // ZERO BOUNCE on the bar
      density: 3.5,
    );

    final bodyDef = BodyDef(
      type: BodyType.kinematic,
      position: initialMidpoint.clone(),
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  /// Update the target carriage positions from player inputs
  void setTargetHeights({required double leftY, required double rightY}) {
    // Mechanical cable tension limiter: enforce maxTiltDifferential
    double lY = leftY;
    double rY = rightY;
    final diff = (lY - rY).abs();

    if (diff > maxTiltDifferential) {
      isOverTilted = true;
      if (!_previousOverTilted) {
        if (isVibrationEnabled?.call() ?? true) {
          HapticFeedback.selectionClick();
        }
        _previousOverTilted = true;
      }
      final mid = (lY + rY) / 2.0;
      final sign = (lY > rY) ? 1.0 : -1.0;
      lY = mid + (sign * maxTiltDifferential / 2.0);
      rY = mid - (sign * maxTiltDifferential / 2.0);
    } else {
      isOverTilted = false;
      _previousOverTilted = false;
    }

    targetLeftY = lY;
    targetRightY = rY;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) return;

    final safeDt = dt > 0 ? dt : 0.016;

    // Smooth spring-damped interpolation toward target carriage heights
    final tFactor = min(1.0, followSpeed * safeDt);
    currentLeftY += (targetLeftY - currentLeftY) * tFactor;
    currentRightY += (targetRightY - currentRightY) * tFactor;

    // Calculate desired midpoint position and incline angle
    final desiredMidY = (currentLeftY + currentRightY) / 2.0;
    final desiredAngle = atan2(currentRightY - currentLeftY, spanWidth);

    // CRITICAL PHYSICS RULE: Drive kinematic body via velocities, not teleportation!
    final curPos = body.position;
    final curAngle = body.angle;

    // 1. Vertical velocity with anti-catapult speed clamps
    double targetVy = (desiredMidY - curPos.y) / safeDt;
    targetVy = targetVy.clamp(-maxUpwardSpeed, maxDownwardSpeed);

    // 2. Linear acceleration clamp: rate-limit velocity jumps to prevent catapulting
    final currentVy = body.linearVelocity.y;
    final maxDeltaV = maxLinearAcceleration * safeDt;
    final vy = currentVy + (targetVy - currentVy).clamp(-maxDeltaV, maxDeltaV);

    // Horizontal velocity is locked to 0 (slides only vertically on rails)
    body.linearVelocity = Vector2(0, vy);

    // 3. Angular velocity clamp: limit maximum rotational speed
    final targetVAng = (desiredAngle - curAngle) / safeDt;
    final vAng = targetVAng.clamp(-maxAngularVelocity, maxAngularVelocity);
    body.angularVelocity = vAng;
  }

  @override
  void render(Canvas canvas) {
    final visualHalfWidth = spanWidth / 2.0 + 1.2;
    final halfH = barThickness / 2.0;
    final barRect = Rect.fromLTRB(-visualHalfWidth, -halfH, visualHalfWidth, halfH);

    // 1. Soft drop shadow under the bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        barRect.translate(0, 0.4),
        Radius.circular(halfH),
      ),
      Paint()
        ..color = theme.barShadowColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );

    // 2. Bar body with cylindrical metallic gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.barHighlightColor,
        theme.barBodyColor,
        theme.barShadowColor,
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(halfH)),
      Paint()..shader = gradient.createShader(barRect),
    );

    // 3. Highlight line along the top ridge
    canvas.drawLine(
      Offset(-visualHalfWidth + 0.8, -halfH * 0.4),
      Offset(visualHalfWidth - 0.8, -halfH * 0.4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 0.18
        ..strokeCap = StrokeCap.round,
    );

    // 4. Theme-specific bar details (peppermint stripes, bamboo nodes, rivets)
    if (theme.type == ThemeType.candyFrosting) {
      _renderCandyStripes(canvas, barRect, halfH);
    } else if (theme.type == ThemeType.jungleBamboo) {
      _renderBambooNodes(canvas, visualHalfWidth, halfH);
    } else if (theme.type == ThemeType.cyberpunkNeon) {
      _renderNeonCore(canvas, visualHalfWidth);
    }

    // 5. Left and Right Carriage Blocks (mechanical collar sleeves on the rails)
    _renderCarriageBlock(canvas, Offset(-spanWidth / 2.0, 0), isLeft: true);
    _renderCarriageBlock(canvas, Offset(spanWidth / 2.0, 0), isLeft: false);
  }

  void _renderCandyStripes(Canvas canvas, Rect rect, double radius) {
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final stripePaint = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: 0.85)
      ..strokeWidth = 1.0;

    for (double sx = rect.left - 5.0; sx < rect.right + 5.0; sx += 3.2) {
      canvas.drawLine(Offset(sx, -radius * 2), Offset(sx + 3.0, radius * 2), stripePaint);
    }
    canvas.restore();
  }

  void _renderBambooNodes(Canvas canvas, double halfW, double halfH) {
    final nodePaint = Paint()
      ..color = const Color(0xFF33691E).withValues(alpha: 0.8)
      ..strokeWidth = 0.35;

    for (double x = -halfW + 4.0; x < halfW; x += 5.5) {
      canvas.drawLine(Offset(x, -halfH), Offset(x, halfH), nodePaint);
      canvas.drawCircle(Offset(x, 0), 0.3, Paint()..color = const Color(0xFFC5E1A5));
    }
  }

  void _renderNeonCore(Canvas canvas, double halfW) {
    canvas.drawLine(
      Offset(-halfW + 2.0, 0),
      Offset(halfW - 2.0, 0),
      Paint()
        ..color = theme.rimGlowColor.withValues(alpha: 0.8)
        ..strokeWidth = 0.3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4),
    );
  }

  void _renderCarriageBlock(Canvas canvas, Offset center, {required bool isLeft}) {
    const w = 1.8;
    const h = 2.8;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      const Radius.circular(0.4),
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(theme.carriageBlockColor, Colors.white, 0.4)!,
        theme.carriageBlockColor,
        Color.lerp(theme.carriageBlockColor, Colors.black, 0.5)!,
      ],
    );

    canvas.drawRRect(rrect, Paint()..shader = gradient.createShader(rrect.outerRect));

    // Outer border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = theme.barHighlightColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.15,
    );

    // Center metallic cable eyelet bolt
    canvas.drawCircle(center, 0.45, Paint()..color = Colors.black.withValues(alpha: 0.6));
    canvas.drawCircle(center, 0.28, Paint()..color = Colors.white.withValues(alpha: 0.95));

    // Illuminated LED level indicator on the rail carriage collar
    final ledColor = isOverTilted ? const Color(0xFFFF1744) : theme.rimGlowColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(isLeft ? -0.4 : 0.4, 0),
          width: 0.35,
          height: 1.6,
        ),
        const Radius.circular(0.18),
      ),
      Paint()
        ..color = ledColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.35),
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
