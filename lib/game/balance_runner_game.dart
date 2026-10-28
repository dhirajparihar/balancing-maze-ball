/// Balance Runner — Core Game Engine
/// Endless vertical arcade physics game matching Reference Design.
/// Lever control, procedural descending track, organic holes, rotating cogs,
/// sliding chevron barriers, and bonus crystals.
library;

import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/audio/audio_manager.dart';
import '../core/services/game_service.dart';
import '../models/balance_runner_models.dart';

enum RunnerState {
  playing,
  paused,
  gameOver,
}

/// Types of track obstacles
enum ObstacleType {
  organicHole,
  rotatingCog,
  slidingBarrier,
  laserBeam,
  bonusCrystal,
}

class TrackObstacle {
  ObstacleType type;
  double x; // world X (0..40)
  double y; // world Y
  double radius;
  double width;
  double height;
  double rotation;
  double rotationSpeed;
  double slideAmplitude;
  double slideSpeed;
  double slidePhase;
  bool directionRight;
  bool isCollected;

  TrackObstacle({
    required this.type,
    required this.x,
    required this.y,
    this.radius = 3.0,
    this.width = 6.0,
    this.height = 2.0,
    this.rotation = 0.0,
    this.rotationSpeed = 1.5,
    this.slideAmplitude = 6.0,
    this.slideSpeed = 2.0,
    this.slidePhase = 0.0,
    this.directionRight = true,
    this.isCollected = false,
  });

  double getCurrentX(double time) {
    if (type == ObstacleType.slidingBarrier) {
      return x + sin(time * slideSpeed + slidePhase) * slideAmplitude;
    }
    return x;
  }
}

class BalanceRunnerGame extends Game {
  final GameService gameService;
  final int? seed;
  final bool isDailyChallenge;

  BalanceRunnerGame({
    required this.gameService,
    this.seed,
    this.isDailyChallenge = false,
  });

  // World dimensions (fixed coordinate system 40 x 75)
  static const double worldWidth = 40.0;
  static const double worldHeight = 75.0;

  // Viewport scale & offset
  double viewScale = 1.0;
  Vector2 viewOffset = Vector2.zero();

  // State
  RunnerState state = RunnerState.playing;
  double distanceMeters = 0.0;
  int score = 0;
  int bonusScore = 0;
  int multiplier = 1;
  double runTime = 0.0;

  // Lever / Balance Bar
  static const double barPivotX = 20.0;
  static const double barPivotY = 58.0;
  static const double barLength = 33.5; // spans across the entire track from rail to rail
  static const double maxTiltAngle = 0.44; // ~25.2 degrees

  double barTilt = 0.0; // Current angle in radians
  double targetTilt = 0.0;
  bool isLeftDragging = false;
  bool isRightDragging = false;
  double lastTouchLeftY = 0.0;
  double lastTouchRightY = 0.0;

  // Ball
  static const double ballRadius = 1.55;
  double ballPosAlongBar = 0.0;
  double ballVelocity = 0.0;
  double ballAngle = 0.0;
  Vector2 ballWorldPos = Vector2(barPivotX, barPivotY - ballRadius);
  bool isFallingOff = false;
  Vector2 fallVelocity = Vector2.zero();
  double ballScale = 1.0;
  bool isSinkingInHole = false;

  // Descending Track
  double trackScrollSpeed = 12.0; // world units per sec
  final List<TrackObstacle> obstacles = [];
  late Random rng;
  double nextSpawnY = -10.0;

  // Visual Skins
  late BallSkinDef ballSkin;
  late BarStyleDef barStyle;

  // Callbacks
  void Function(int distance, int score, int multiplier, double time)? onHudUpdate;
  void Function(int distance, int score)? onGameOver;

  @override
  Color backgroundColor() => const Color(0xFF061019);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

    // Load equipped skins
    ballSkin = BallSkinDef.getById(gameService.playerData.equippedMarbleSkin);
    barStyle = BarStyleDef.getById(gameService.playerData.equippedBarSkin);

    // Initial safe track segment
    _generateInitialTrack();
  }

  void _generateInitialTrack() {
    obstacles.clear();
    // Warm-up track (first 60 units have gentle side holes only)
    for (double y = 40.0; y >= -150.0; y -= 16.0) {
      _spawnTrackRow(y);
    }
    nextSpawnY = -150.0;
  }

  void _spawnTrackRow(double y) {
    // Current difficulty tier based on distance
    final double dist = distanceMeters;
    final double safeWidth = dist < 500
        ? 18.0
        : dist < 1500
            ? 13.0
            : dist < 3000
                ? 10.0
                : 8.5;

    // Center corridor wander
    final double corridorCenter = 20.0 + sin(y * 0.08) * 7.0;

    // 1. Organic Holes on left and right borders
    final double leftHoleW = max(4.0, (corridorCenter - safeWidth / 2) - 4.0);
    if (leftHoleW > 4.0) {
      obstacles.add(
        TrackObstacle(
          type: ObstacleType.organicHole,
          x: 4.0 + leftHoleW / 2,
          y: y,
          width: leftHoleW,
          height: 9.0 + rng.nextDouble() * 5.0,
          radius: 3.5,
        ),
      );
    }

    final double rightHoleW = max(4.0, 36.0 - (corridorCenter + safeWidth / 2));
    if (rightHoleW > 4.0) {
      obstacles.add(
        TrackObstacle(
          type: ObstacleType.organicHole,
          x: 36.0 - rightHoleW / 2,
          y: y,
          width: rightHoleW,
          height: 9.0 + rng.nextDouble() * 5.0,
          radius: 3.5,
        ),
      );
    }

    // 2. Bonus Crystals along the safe lane
    if (rng.nextDouble() < 0.45) {
      obstacles.add(
        TrackObstacle(
          type: ObstacleType.bonusCrystal,
          x: corridorCenter + (rng.nextDouble() - 0.5) * 4.0,
          y: y - 7.0,
          radius: 1.2,
        ),
      );
    }

    // 3. Medium & Hard: Rotating Cogs & Sliding Chevron Barriers
    if (dist >= 450 && rng.nextDouble() < (dist < 1500 ? 0.35 : 0.55)) {
      final isCog = rng.nextBool() || dist >= 2500;
      if (isCog) {
        obstacles.add(
          TrackObstacle(
            type: ObstacleType.rotatingCog,
            x: corridorCenter + (rng.nextBool() ? -4.5 : 4.5),
            y: y - 6.0,
            radius: 3.2,
            rotationSpeed: (rng.nextBool() ? 1.8 : -1.8) * (1.0 + dist / 3000.0),
          ),
        );
      } else {
        obstacles.add(
          TrackObstacle(
            type: ObstacleType.slidingBarrier,
            x: corridorCenter,
            y: y - 5.0,
            width: 7.0,
            height: 1.6,
            slideAmplitude: 4.5,
            slideSpeed: 2.2 + (dist / 2000.0),
            directionRight: rng.nextBool(),
          ),
        );
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final scaleX = size.x / worldWidth;
    final scaleY = size.y / worldHeight;
    viewScale = min(scaleX, scaleY);
    viewOffset = Vector2(
      (size.x - worldWidth * viewScale) / 2.0,
      (size.y - worldHeight * viewScale) / 2.0,
    );
  }

  // ---- Lever Drag Controls ----

  void handlePointerDown(Offset localPosition) {
    if (state != RunnerState.playing) return;
    final worldX = (localPosition.dx - viewOffset.x) / viewScale;
    final worldY = (localPosition.dy - viewOffset.y) / viewScale;

    if (worldX < barPivotX) {
      isLeftDragging = true;
      lastTouchLeftY = worldY;
    } else {
      isRightDragging = true;
      lastTouchRightY = worldY;
    }
  }

  void handlePointerMove(Offset localPosition) {
    if (state != RunnerState.playing) return;
    final worldX = (localPosition.dx - viewOffset.x) / viewScale;
    final worldY = (localPosition.dy - viewOffset.y) / viewScale;

    final sensitivity = gameService.playerData.controlSensitivity;

    if (worldX < barPivotX || isLeftDragging) {
      if (isLeftDragging) {
        final dy = worldY - lastTouchLeftY;
        // Dragging left end DOWN increases left depth (negative tilt)
        targetTilt = (targetTilt - dy * 0.045 * sensitivity).clamp(-maxTiltAngle, maxTiltAngle);
        lastTouchLeftY = worldY;
      }
    }
    if (worldX >= barPivotX || isRightDragging) {
      if (isRightDragging) {
        final dy = worldY - lastTouchRightY;
        // Dragging right end DOWN tilts right end down (positive tilt)
        targetTilt = (targetTilt + dy * 0.045 * sensitivity).clamp(-maxTiltAngle, maxTiltAngle);
        lastTouchRightY = worldY;
      }
    }
  }

  void handlePointerUp(Offset localPosition) {
    final worldX = (localPosition.dx - viewOffset.x) / viewScale;
    if (worldX < barPivotX) {
      isLeftDragging = false;
    } else {
      isRightDragging = false;
    }
  }

  @override
  void update(double dt) {
    if (state != RunnerState.playing) return;

    runTime += dt;

    // 1. Lever Bar Tilt Physics
    // Ease bar back slightly towards 0 when not dragging
    if (!isLeftDragging && !isRightDragging) {
      targetTilt += (0.0 - targetTilt) * min(1.0, 3.2 * dt);
    }
    barTilt += (targetTilt - barTilt) * min(1.0, 18.0 * dt);

    // 2. Ball Physics on Inclined Lever
    if (!isFallingOff && !isSinkingInHole) {
      const double gravityG = 38.0; // Responsive gravity along incline
      const double friction = 0.982;

      final double inclineAcc = sin(barTilt) * gravityG;
      ballVelocity = (ballVelocity + inclineAcc * dt) * pow(friction, dt * 60);
      ballPosAlongBar += ballVelocity * dt;

      // End-collar bumper constraints: keep the ball securely on the bar
      final halfLength = (barLength / 2.0) - ballRadius - 0.5;
      if (ballPosAlongBar < -halfLength) {
        ballPosAlongBar = -halfLength;
        if (ballVelocity < -1.5 && gameService.playerData.vibrationEnabled) {
          HapticFeedback.selectionClick();
        }
        ballVelocity = -ballVelocity * 0.35; // Soft collar bounce
      } else if (ballPosAlongBar > halfLength) {
        ballPosAlongBar = halfLength;
        if (ballVelocity > 1.5 && gameService.playerData.vibrationEnabled) {
          HapticFeedback.selectionClick();
        }
        ballVelocity = -ballVelocity * 0.35; // Soft collar bounce
      }

      // Ball rotation
      ballAngle += (ballVelocity / ballRadius) * dt;

      // Calculate world coordinates from bar pivot
      final cosT = cos(barTilt);
      final sinT = sin(barTilt);
      ballWorldPos = Vector2(
        barPivotX + ballPosAlongBar * cosT - sinT * ballRadius,
        barPivotY + ballPosAlongBar * sinT - cosT * ballRadius,
      );
    } else if (isFallingOff) {
      // Free falling down into the abyss (knocked by hazard)
      fallVelocity.y += 90.0 * dt;
      ballWorldPos += fallVelocity * dt;
      ballAngle += 4.0 * dt;

      if (ballWorldPos.y > worldHeight + 10.0) {
        _triggerGameOver();
      }
    } else if (isSinkingInHole) {
      // Suction down into the dark organic hole
      ballScale = max(0.0, ballScale - 3.5 * dt);
      ballWorldPos.y += 4.0 * dt;
      if (ballScale <= 0.05) {
        _triggerGameOver();
      }
    }

    // 3. Track Scrolling & Difficulty Scaling
    trackScrollSpeed = 12.0 + (distanceMeters / 180.0).clamp(0.0, 18.0);
    final double scrollDelta = trackScrollSpeed * dt;
    distanceMeters += scrollDelta * 0.7;

    // Multiplier calculation matching design doc
    if (distanceMeters < 500) {
      multiplier = 1;
    } else if (distanceMeters < 1500) {
      multiplier = 2;
    } else if (distanceMeters < 3000) {
      multiplier = 4;
    } else {
      multiplier = 5;
    }

    // Continuous score: Distance * Multiplier + bonus collectibles
    score = (distanceMeters * multiplier).toInt() + bonusScore;

    // 4. Update Track Obstacles & Collision
    for (int i = obstacles.length - 1; i >= 0; i--) {
      final obs = obstacles[i];
      obs.y += scrollDelta;
      obs.rotation += obs.rotationSpeed * dt;

      // Collision checks with ball (only when ball is on bar or recently active)
      if (!isFallingOff && !isSinkingInHole) {
        _checkObstacleCollision(obs);
      }

      // Despawn obstacles below screen
      if (obs.y > worldHeight + 15.0) {
        obstacles.removeAt(i);
      }
    }

    // Spawn new obstacles at top
    nextSpawnY += scrollDelta;
    if (nextSpawnY >= -10.0) {
      _spawnTrackRow(-20.0);
      nextSpawnY = -28.0;
    }

    // Notify HUD
    onHudUpdate?.call(distanceMeters.toInt(), score, multiplier, runTime);
  }

  void _checkObstacleCollision(TrackObstacle obs) {
    final curX = obs.getCurrentX(runTime);
    final dx = ballWorldPos.x - curX;
    final dy = ballWorldPos.y - obs.y;
    final dist = sqrt(dx * dx + dy * dy);

    switch (obs.type) {
      case ObstacleType.bonusCrystal:
        if (!obs.isCollected && dist < (obs.radius + ballRadius + 0.8)) {
          obs.isCollected = true;
          bonusScore += 150;
          gameService.audioManager.playSfx(SoundEffect.coinCollect);
          if (gameService.playerData.vibrationEnabled) {
            HapticFeedback.lightImpact();
          }
        }
        break;

      case ObstacleType.organicHole:
        // Check if ball center falls inside hole area
        final halfW = obs.width / 2.0;
        final halfH = obs.height / 2.0;
        if (dx.abs() < (halfW - 0.4) && dy.abs() < (halfH - 0.3)) {
          isSinkingInHole = true;
          gameService.audioManager.playSfx(SoundEffect.fallOut);
          if (gameService.playerData.vibrationEnabled) {
            HapticFeedback.heavyImpact();
          }
        }
        break;

      case ObstacleType.rotatingCog:
        if (dist < (obs.radius + ballRadius - 0.3)) {
          isFallingOff = true;
          fallVelocity = Vector2(dx * 4.0, -8.0);
          gameService.audioManager.playSfx(SoundEffect.marbleCollision);
          if (gameService.playerData.vibrationEnabled) {
            HapticFeedback.heavyImpact();
          }
        }
        break;

      case ObstacleType.slidingBarrier:
        if (dx.abs() < (obs.width / 2.0 + ballRadius) && dy.abs() < (obs.height / 2.0 + ballRadius)) {
          isFallingOff = true;
          fallVelocity = Vector2(dx.sign * 6.0, -6.0);
          gameService.audioManager.playSfx(SoundEffect.marbleCollision);
          if (gameService.playerData.vibrationEnabled) {
            HapticFeedback.heavyImpact();
          }
        }
        break;

      case ObstacleType.laserBeam:
        break;
    }
  }

  void _triggerGameOver() {
    state = RunnerState.gameOver;
    onGameOver?.call(distanceMeters.toInt(), score);
  }

  void pause() {
    state = RunnerState.paused;
  }

  void resume() {
    state = RunnerState.playing;
  }

  void restart() {
    state = RunnerState.playing;
    distanceMeters = 0.0;
    score = 0;
    bonusScore = 0;
    multiplier = 1;
    runTime = 0.0;
    barTilt = 0.0;
    targetTilt = 0.0;
    ballPosAlongBar = 0.0;
    ballVelocity = 0.0;
    ballAngle = 0.0;
    ballScale = 1.0;
    isFallingOff = false;
    isSinkingInHole = false;
    ballWorldPos = Vector2(barPivotX, barPivotY - ballRadius);
    rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    _generateInitialTrack();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(viewOffset.x, viewOffset.y);
    canvas.scale(viewScale, viewScale);

    // 1. Background Void with Cyber Nebula
    final bgRect = const Rect.fromLTWH(0, 0, worldWidth, worldHeight);
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.2),
        radius: 1.1,
        colors: [Color(0xFF0F2238), Color(0xFF071220), Color(0xFF03070E)],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // 2. Track Background Plate with Glowing Rails
    _renderSideRails(canvas);

    // 3. Render Descending Track Obstacles (Holes, Cogs, Barriers, Crystals)
    _renderObstacles(canvas);

    // 4. Render Tilting Balance Bar & Collars
    _renderBalanceBar(canvas);

    // 5. Render Rolling Metallic Ball
    _renderBall(canvas);

    canvas.restore();
  }

  void _renderSideRails(Canvas canvas) {
    final railGlow = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final railCore = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 1.2;

    // Left neon rail
    canvas.drawLine(const Offset(3.5, 0), const Offset(3.5, worldHeight), railGlow);
    canvas.drawLine(const Offset(3.5, 0), const Offset(3.5, worldHeight), railCore);

    // Right neon rail
    canvas.drawLine(const Offset(36.5, 0), const Offset(36.5, worldHeight), railGlow);
    canvas.drawLine(const Offset(36.5, 0), const Offset(36.5, worldHeight), railCore);
  }

  void _renderObstacles(Canvas canvas) {
    for (final obs in obstacles) {
      if (obs.type == ObstacleType.organicHole) {
        // Deep space black void cutout with cyan glowing rim
        final holeRect = Rect.fromCenter(
          center: Offset(obs.x, obs.y),
          width: obs.width,
          height: obs.height,
        );
        final rrect = RRect.fromRectAndRadius(holeRect, Radius.circular(obs.radius));

        // Void inner shadow
        canvas.drawRRect(rrect, Paint()..color = const Color(0xFF03070E));

        // Cyan rim bevel & glow
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
        );
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = const Color(0xFF26C6DA)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.3,
        );
      } else if (obs.type == ObstacleType.rotatingCog) {
        _renderRotatingCog(canvas, obs);
      } else if (obs.type == ObstacleType.slidingBarrier) {
        _renderSlidingBarrier(canvas, obs);
      } else if (obs.type == ObstacleType.bonusCrystal && !obs.isCollected) {
        _renderBonusCrystal(canvas, obs);
      }
    }
  }

  void _renderRotatingCog(Canvas canvas, TrackObstacle obs) {
    canvas.save();
    canvas.translate(obs.x, obs.y);
    canvas.rotate(obs.rotation);

    // Gear body (metallic dark rim with teeth)
    final gearPaint = Paint()..color = const Color(0xFF212529);
    canvas.drawCircle(Offset.zero, obs.radius, gearPaint);

    // 8 Gear Teeth
    final toothPaint = Paint()..color = const Color(0xFF343A40);
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      canvas.save();
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(0, -obs.radius), width: 1.0, height: 1.2),
        toothPaint,
      );
      canvas.restore();
    }

    // Fiery Orange Glowing Core (matching Images 4, 5, 6!)
    final coreGradient = RadialGradient(
      colors: const [
        Color(0xFFFFF176),
        Color(0xFFFF9100),
        Color(0xFFFF3D00),
        Color(0x00FF3D00),
      ],
      stops: const [0.0, 0.4, 0.8, 1.0],
    );
    canvas.drawCircle(
      Offset.zero,
      obs.radius * 0.75,
      Paint()..shader = coreGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: obs.radius * 0.75)),
    );

    // Glowing core center dot
    canvas.drawCircle(Offset.zero, 0.8, Paint()..color = Colors.white);

    canvas.restore();
  }

  void _renderSlidingBarrier(Canvas canvas, TrackObstacle obs) {
    final curX = obs.getCurrentX(runTime);
    final rect = Rect.fromCenter(center: Offset(curX, obs.y), width: obs.width, height: obs.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(0.8));

    // Cyan glowing barrier background
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF00384D)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.35,
    );

    // Chevron Directional Arrows `>>>` inside barrier
    final chevronPaint = Paint()
      ..color = const Color(0xFF80DEEA)
      ..strokeWidth = 0.4
      ..style = PaintingStyle.stroke;

    final dir = obs.directionRight ? 1.0 : -1.0;
    for (double dx = -obs.width * 0.3; dx <= obs.width * 0.3; dx += 1.8) {
      final path = Path();
      path.moveTo(curX + dx - dir * 0.5, obs.y - 0.5);
      path.lineTo(curX + dx + dir * 0.5, obs.y);
      path.lineTo(curX + dx - dir * 0.5, obs.y + 0.5);
      canvas.drawPath(path, chevronPaint);
    }
  }

  void _renderBonusCrystal(Canvas canvas, TrackObstacle obs) {
    canvas.save();
    canvas.translate(obs.x, obs.y);
    canvas.rotate(runTime * 2.0);

    // Diamond shape
    final path = Path()
      ..moveTo(0, -obs.radius)
      ..lineTo(obs.radius * 0.7, 0)
      ..lineTo(0, obs.radius)
      ..lineTo(-obs.radius * 0.7, 0)
      ..close();

    // Glow aura
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Core
    canvas.drawPath(
      path,
      Paint()..color = Colors.white,
    );

    canvas.restore();
  }

  void _renderBalanceBar(Canvas canvas) {
    canvas.save();
    canvas.translate(barPivotX, barPivotY);
    canvas.rotate(barTilt);

    final halfL = barLength / 2.0;
    final barRect = Rect.fromLTWH(-halfL, -0.9, barLength, 1.8);

    // Bar Glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(0.9)),
      Paint()
        ..color = barStyle.glowColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Bar Gradient Body
    final barGradient = LinearGradient(
      colors: barStyle.rodGradient,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(0.9)),
      Paint()..shader = barGradient.createShader(barRect),
    );

    // End Collars / Carriages & Bumpers
    final collarPaint = Paint()..color = const Color(0xFF1E293B);
    final collarBevel = Paint()
      ..color = barStyle.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.35;

    // Left collar bumper
    final leftCollar = Rect.fromLTWH(-halfL - 0.4, -1.8, 1.5, 3.6);
    canvas.drawRRect(RRect.fromRectAndRadius(leftCollar, const Radius.circular(0.6)), collarPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftCollar, const Radius.circular(0.6)), collarBevel);

    // Right collar bumper
    final rightCollar = Rect.fromLTWH(halfL - 1.1, -1.8, 1.5, 3.6);
    canvas.drawRRect(RRect.fromRectAndRadius(rightCollar, const Radius.circular(0.6)), collarPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightCollar, const Radius.circular(0.6)), collarBevel);

    // Center Pivot Indicator
    canvas.drawCircle(Offset.zero, 1.1, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset.zero, 0.55, Paint()..color = barStyle.primaryColor);

    canvas.restore();
  }

  void _renderBall(Canvas canvas) {
    if (ballScale <= 0.01) return;

    canvas.save();
    canvas.translate(ballWorldPos.x, ballWorldPos.y);
    canvas.scale(ballScale, ballScale);
    canvas.rotate(ballAngle);

    final r = ballRadius;

    // Ball Drop Shadow on Bar
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, r * 0.8), width: r * 1.8, height: r * 0.5),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // 3D Spherical Radial Gradient
    final sphereGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.9,
      colors: ballSkin.gradientColors,
      stops: ballSkin.stops,
    );

    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()..shader = sphereGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
    );

    // Specular Highlight Spot
    canvas.drawCircle(
      Offset(-r * 0.35, -r * 0.38),
      r * 0.26,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    canvas.restore();
  }
}
