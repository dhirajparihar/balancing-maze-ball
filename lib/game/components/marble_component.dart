/// Marble component — Forge2D dynamic rigid body.
/// Continuous collision detection (bullet: true), faceplate friction damping,
/// hole fall animation (scale 1.0 -> 0.45, centroid suction, shadow fade),
/// and theme-specific procedural shader rendering (ceramic, copper, orb, wood, jawbreaker, sun).
library;

import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio/audio_manager.dart';
import '../../models/maze_theme_config.dart';
import '../balancing_maze_game.dart';
import 'lifting_bar_component.dart';

typedef FallCompleteCallback = void Function();

class MarbleComponent extends BodyComponent<BalancingMazeGame>
    with ContactCallbacks {
  final Vector2 initialPosition;
  final double radius;
  final MazeThemeConfig theme;

  double _rotation = 0.0;
  double _pulseTime = 0.0;
  DateTime _lastImpactTime = DateTime.fromMillisecondsSinceEpoch(0);
  double _rollAudioTimer = 0.0;

  // Fall animation state (falling through hole into chute)
  bool _isFalling = false;
  double _fallScale = 1.0;
  double _fallElapsed = 0.0;
  static const double _fallDuration = 0.32; // 320ms
  Vector2? _holeCentroid;
  FallCompleteCallback? _onFallComplete;

  bool get isFalling => _isFalling;

  // Pre-allocated reusable Paint objects (Zero Allocation in 60/120 FPS render loop)
  final Paint _shadowPaint = Paint();
  final Paint _spherePaint = Paint();
  final Paint _glowPaint = Paint();
  final Paint _glintPaint = Paint();

  MarbleComponent({
    required this.initialPosition,
    this.radius = 1.35,
    required this.theme,
  }) : super(priority: 30);

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      density: 5.5, // Heavy marble with realistic mass & inertia
      friction: 0.50, // Firm surface friction against the lifting bar
      restitution: 0.0, // ZERO BOUNCE — marble lands dead on the bar
    );

    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition.clone(),
      bullet: true, // Continuous collision detection against lifting bar
      linearDamping: 0.60, // Heavy friction dragging against vertical faceplate
      angularDamping: 0.40,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  /// Begin the fall-through-hole sequence
  void fallIntoHole(Vector2 centroid, {required FallCompleteCallback onComplete}) {
    if (_isFalling) return;
    _isFalling = true;
    _fallElapsed = 0.0;
    _fallScale = 1.0;
    _holeCentroid = centroid;
    _onFallComplete = onComplete;

    // Disable physical collision with lifting bar so it drops into the rear chute
    for (final fixture in body.fixtures) {
      fixture.filterData.maskBits = 0; // Collides with nothing
    }
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0.0;
  }

  /// Reset marble to active rolling state
  void reset(Vector2 newPosition) {
    _isFalling = false;
    _fallScale = 1.0;
    _fallElapsed = 0.0;
    _holeCentroid = null;
    _onFallComplete = null;

    body.setTransform(newPosition, 0.0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0.0;

    // Restore full collision filter
    for (final fixture in body.fixtures) {
      fixture.filterData.maskBits = 0xFFFF;
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (_isFalling) return;

    final now = DateTime.now();
    if (now.difference(_lastImpactTime).inMilliseconds < 90) return;
    _lastImpactTime = now;

    final speed = body.linearVelocity.length;
    if (speed < 1.4) return;

    final isRail = other == 'rail' || other == 'top_stop';
    if (isRail) {
      game.registerWallBounce();
      if (game.gameService.playerData.vibrationEnabled) {
        if (theme.type == ThemeType.steampunkBrass) {
          HapticFeedback.heavyImpact();
        } else if (theme.type == ThemeType.jungleBamboo) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.selectionClick();
        }
      }
      game.gameService.audioManager.playThemeClank(theme.type);
    } else if (other is LiftingBarComponent) {
      if (speed > 3.5) {
        if (game.gameService.playerData.vibrationEnabled) {
          HapticFeedback.lightImpact();
        }
        game.gameService.audioManager.playThemeClank(theme.type);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) return;

    _rotation = body.angle;
    _pulseTime += dt;

    // Rolling friction acoustic rumble when rolling with velocity on the bar
    if (!_isFalling) {
      _rollAudioTimer += dt;
      if (_rollAudioTimer > 0.40 && body.linearVelocity.x.abs() > 3.2) {
        _rollAudioTimer = 0.0;
        game.gameService.audioManager.playSfx(SoundEffect.marbleRoll);
      }
    }

    if (_isFalling && _holeCentroid != null) {
      _fallElapsed += dt;
      final progress = (_fallElapsed / _fallDuration).clamp(0.0, 1.0);

      // Scale from 1.0 -> 0.45
      _fallScale = 1.0 - (progress * 0.55);

      // Smoothly vacuum marble center toward hole centroid
      final curPos = body.position;
      final toCentroid = _holeCentroid! - curPos;
      body.setTransform(
        curPos + toCentroid * min(1.0, 12.0 * dt),
        body.angle + 10.0 * dt,
      );

      if (progress >= 1.0) {
        _isFalling = false;
        _onFallComplete?.call();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final curRadius = radius * _fallScale;
    final alpha = _fallScale.clamp(0.2, 1.0);
    final equippedSkin = game.gameService.playerData.equippedMarbleSkin;
    final hasCustomSkin = equippedSkin.isNotEmpty && equippedSkin != 'default' && equippedSkin != 'marble_default';

    canvas.save();

    // 1. Marble dynamic 3D drop shadow cast onto the board faceplate
    final shadowOffset = Offset(0.35 * _fallScale, 0.55 * _fallScale);
    _shadowPaint
      ..color = Colors.black.withValues(alpha: alpha * 0.60)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.75 * _fallScale);
    canvas.drawCircle(shadowOffset, curRadius * 1.15, _shadowPaint);

    // 2. Base sphere body with 3D spherical lighting gradient
    final sphereRect = Rect.fromCircle(center: Offset.zero, radius: curRadius);
    final List<Color> gradientColors;
    if (hasCustomSkin) {
      gradientColors = _getSkinColors(equippedSkin, alpha);
    } else {
      gradientColors = [
        theme.marbleSpecularColor.withValues(alpha: alpha),
        theme.marbleHighlightColor.withValues(alpha: alpha),
        theme.marbleBaseColor.withValues(alpha: alpha),
        Color.lerp(theme.marbleBaseColor, Colors.black, 0.55)!.withValues(alpha: alpha),
      ];
    }

    final sphereGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.95,
      colors: gradientColors,
      stops: gradientColors.length == 3 ? const [0.0, 0.45, 1.0] : const [0.0, 0.35, 0.75, 1.0],
    );

    _spherePaint.shader = sphereGradient.createShader(sphereRect);
    canvas.drawCircle(Offset.zero, curRadius, _spherePaint);

    // 3. Theme-specific surface details
    canvas.save();
    canvas.rotate(_rotation);
    _renderThemeDetail(canvas, curRadius, alpha);
    canvas.restore();

    // 4. Glowing energy aura for plasma/sun themes (respect reduced motion)
    final reducedMotion = game.gameService.playerData.reducedMotion;
    if (theme.marbleGlows && !reducedMotion) {
      final glowPulse = 0.8 + 0.2 * sin(_pulseTime * 5.0);
      _glowPaint
        ..color = theme.rimGlowColor.withValues(alpha: 0.25 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      canvas.drawCircle(Offset.zero, curRadius * 1.35 * glowPulse, _glowPaint);
    }

    // 5. Specular lens glint
    final glintCenter = Offset(-curRadius * 0.32, -curRadius * 0.36);
    _glintPaint.shader = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.95 * alpha),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: glintCenter, radius: curRadius * 0.24));
    canvas.drawCircle(glintCenter, curRadius * 0.24, _glintPaint);

    canvas.restore();
  }

  void _renderThemeDetail(Canvas canvas, double r, double alpha) {
    switch (theme.type) {
      case ThemeType.candyFrosting:
        // Swirled jawbreaker concentric colored rings
        final ringPaint = Paint()
          ..color = const Color(0xFFFF4081).withValues(alpha: 0.3 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.18;
        canvas.drawCircle(Offset.zero, r * 0.65, ringPaint);
        canvas.drawCircle(Offset.zero, r * 0.35, ringPaint);
        break;

      case ThemeType.jungleBamboo:
        // Polished hardwood grain lines
        final grainPaint = Paint()
          ..color = const Color(0xFF4E342E).withValues(alpha: 0.3 * alpha)
          ..strokeWidth = 0.14
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(-r * 0.7, -r * 0.2), Offset(r * 0.7, -r * 0.2), grainPaint);
        canvas.drawLine(Offset(-r * 0.8, r * 0.2), Offset(r * 0.8, r * 0.2), grainPaint);
        break;

      case ThemeType.cyberpunkNeon:
        // Glowing cyan energy equator ring
        canvas.drawCircle(
          Offset.zero,
          r * 0.6,
          Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: 0.6 * alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.2,
        );
        break;

      case ThemeType.steampunkBrass:
        // Lathe-turned polished brass circumference grooves
        final groovePaint = Paint()
          ..color = const Color(0xFF3E2723).withValues(alpha: 0.35 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.15;
        canvas.drawCircle(Offset.zero, r * 0.72, groovePaint);
        break;

      case ThemeType.deepSpace:
        // Plasma solar flare arcs
        final flarePaint = Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: 0.4 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.22;
        canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r * 0.5), 0, pi * 1.2, false, flarePaint);
        break;

      case ThemeType.classicCyan:
        // Minimal subtle ceramic reflection marks
        final markPaint = Paint()
          ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.25 * alpha)
          ..strokeWidth = 0.12
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(-r * 0.35, 0), Offset(r * 0.35, 0), markPaint);
        break;
    }
  }

  List<Color> _getSkinColors(String skinId, double alpha) {
    switch (skinId) {
      case 'marble_gold':
        return [
          Colors.white.withValues(alpha: alpha),
          const Color(0xFFFFD700).withValues(alpha: alpha),
          const Color(0xFFB78103).withValues(alpha: alpha),
        ];
      case 'marble_ruby':
        return [
          Colors.white.withValues(alpha: alpha),
          const Color(0xFFFF1744).withValues(alpha: alpha),
          const Color(0xFF880E4F).withValues(alpha: alpha),
        ];
      case 'marble_sapphire':
        return [
          Colors.white.withValues(alpha: alpha),
          const Color(0xFF00B0FF).withValues(alpha: alpha),
          const Color(0xFF0D47A1).withValues(alpha: alpha),
        ];
      case 'marble_emerald':
        return [
          Colors.white.withValues(alpha: alpha),
          const Color(0xFF00E676).withValues(alpha: alpha),
          const Color(0xFF1B5E20).withValues(alpha: alpha),
        ];
      case 'marble_neon':
        return [
          Colors.white.withValues(alpha: alpha),
          const Color(0xFF00E5FF).withValues(alpha: alpha),
          const Color(0xFFE040FB).withValues(alpha: alpha),
        ];
      case 'marble_galaxy':
        return [
          const Color(0xFFE040FB).withValues(alpha: alpha),
          const Color(0xFF3D5AFE).withValues(alpha: alpha),
          const Color(0xFF050520).withValues(alpha: alpha),
        ];
      case 'marble_crystal':
        return [
          Colors.white.withValues(alpha: alpha),
          const Color(0xFFE0F7FA).withValues(alpha: alpha),
          const Color(0xFF80DEEA).withValues(alpha: alpha),
        ];
      default:
        return [
          theme.marbleSpecularColor.withValues(alpha: alpha),
          theme.marbleHighlightColor.withValues(alpha: alpha),
          theme.marbleBaseColor.withValues(alpha: alpha),
          Color.lerp(theme.marbleBaseColor, Colors.black, 0.55)!.withValues(alpha: alpha),
        ];
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
