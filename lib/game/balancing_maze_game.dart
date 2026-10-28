/// Balancing Maze — Forge2D Game Engine.
/// Fixed aspect-ratio world (40.0 x 75.0), 35.0 downward gravity,
/// kinematic lifting bar, continuous dynamic marble, three-zone hole suction physics,
/// and sequential target progression ("Ice Cold Beer" mode).
library;

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import '../core/audio/audio_manager.dart';
import '../core/services/game_service.dart';
import '../models/maze_theme_config.dart';
import 'components/background_parallax_component.dart';
import 'components/lifting_bar_component.dart';
import 'components/marble_component.dart';
import 'components/organic_board_component.dart';
import 'components/pulley_cable_component.dart';
import 'systems/level_definitions.dart';

enum GamePlayState {
  menu,
  playing,
  paused,
  levelCompleted,
  levelFailed,
}

class BalancingMazeGame extends Forge2DGame {
  final GameService gameService;

  // Level & Theme
  BoardLevel currentLevel;
  MazeThemeConfig currentTheme;

  // Components
  BackgroundParallaxComponent? _background;
  OrganicBoardComponent? _organicBoard;
  PulleyCableComponent? _pulleyCables;
  LiftingBarComponent? _liftingBar;
  MarbleComponent? _marble;
  final List<Body> _railBoundaries = [];

  // Game Play State
  GamePlayState playState = GamePlayState.menu;
  int currentSequentialStep = 1;
  int score = 0;
  int stars = 0;
  double elapsedTime = 0.0; // Cumulative run elapsed time across all attempts
  double attemptElapsedTime = 0.0; // Elapsed time on current attempt (resets on respawn)
  double remainingTime = 120.0;
  bool isSoundEnabled = true;

  // Settings
  double controlSensitivity = 1.0;
  bool isRelativeDrag = true;

  // Normalized Slider Heights: 0.0 (bottom = 61.5) to 1.0 (top = 16.5)
  double leftSliderNorm = 0.0;
  double rightSliderNorm = 0.0;

  // Rim suction physics constants: 16.0 provides subtle edge tension without unfair vacuum
  static const double rimSuctionForce = 16.0;
  double _lastSuctionHapticTime = 0.0;

  void triggerHaptic(void Function() hapticCall) {
    if (gameService.playerData.vibrationEnabled) {
      hapticCall();
    }
  }

  // Persistence & Multi-Ghost Replay (0.6s instant retry & Personal Best)
  int attempts = 1;
  int wallBounces = 0;
  final List<Vector2> _currentRunTrail = [];

  /// Current linear speed of the rolling marble in world units/sec
  double get marbleSpeed => _marble?.body.linearVelocity.length ?? 0.0;
  Vector2 get marblePosition => _marble?.body.position ?? Vector2.zero();
  List<Vector2>? ghostTrail;
  Vector2? ghostFallPoint;
  List<Vector2>? personalBestGhostTrail;
  double _trailSampleTimer = 0.0;
  bool _isAutoRespawning = false;

  // Decoupled State Callbacks — Scalability Pillar 3
  void Function(int stars, int score, double time, int wallBounces)? onGoalReached;
  void Function(OrganicHole hole, int attempts)? onHoleFell;
  void Function(int wallBounces)? onWallBounce;
  void Function(double remainingTime, double elapsedTime)? onTimerTick;
  void Function(GamePlayState state)? onStateChanged;

  final bool startInMenu;

  BalancingMazeGame({
    required this.gameService,
    BoardLevel? initialLevel,
    MazeThemeConfig? initialTheme,
    this.startInMenu = false,
    this.onGoalReached,
    this.onHoleFell,
    this.onWallBounce,
    this.onTimerTick,
    this.onStateChanged,
  })  : currentLevel = initialLevel ?? LevelDefinitions.level1Training,
        currentTheme = initialTheme ?? MazeThemeConfig.classicCyan,
        controlSensitivity = gameService.playerData.controlSensitivity,
        super(
          gravity: Vector2(0, (initialLevel ?? LevelDefinitions.level1Training).gravityY),
          zoom: 1.0,
        );

  @override
  Color backgroundColor() => currentTheme.voidBgColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set camera anchor to top-left
    camera.viewfinder.anchor = Anchor.topLeft;

    // Load initial level layout
    await loadLevel(currentLevel.id);
    if (startInMenu) {
      playState = GamePlayState.menu;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _setupFixedAspectRatioCamera(size);
  }

  /// Sets up a fixed aspect-ratio viewport (40.0 x 75.0) centered in the camera
  void _setupFixedAspectRatioCamera(Vector2 screenSize) {
    const worldW = 40.0;
    const worldH = 75.0;

    final zoomX = screenSize.x / worldW;
    final zoomY = screenSize.y / worldH;
    final zoom = min(zoomX, zoomY);

    camera.viewfinder.zoom = zoom;

    // Center the 40x75 world in the screen viewport
    final offsetX = (screenSize.x - worldW * zoom) / 2.0;
    final offsetY = (screenSize.y - worldH * zoom) / 2.0;

    camera.viewfinder.position = Vector2(
      -offsetX / zoom,
      -offsetY / zoom,
    );
  }

  /// Register a wall bounce against the left or right guide rail
  void registerWallBounce() {
    wallBounces++;
    onWallBounce?.call(wallBounces);
  }

  /// Load a level by ID or special ID (999 = Daily Challenge)
  Future<void> loadLevel(int levelId) async {
    final lvl = (levelId == 999)
        ? DailyChallengeService.getTodaysChallenge()
        : LevelDefinitions.getById(levelId);
    await loadLevelConfig(lvl);
  }

  /// Load a LevelConfig / BoardLevel instance cleanly
  Future<void> loadLevelConfig(BoardLevel level) async {
    currentLevel = level;
    currentTheme = MazeThemeConfig.getById(currentLevel.themeId);

    // Apply dynamic modifier gravity to Forge2D world (e.g. 18.0 for Low Gravity Day)
    world.gravity = Vector2(0, currentLevel.gravityY);

    // Reset game tracking state
    playState = GamePlayState.playing;
    currentSequentialStep = 1;
    score = 0;
    stars = 0;
    wallBounces = 0;
    attempts = 1;
    elapsedTime = 0.0;
    attemptElapsedTime = 0.0;
    remainingTime = currentLevel.timerSeconds.toDouble();
    leftSliderNorm = 0.0;
    rightSliderNorm = 0.0;

    // Reset taped hole shields
    for (final h in currentLevel.holes) {
      h.resetTape();
    }

    await _clearLevel();
    await _buildLevel();

    onStateChanged?.call(playState);
  }

  /// Switch the active visual theme dynamically
  void switchTheme(MazeThemeConfig newTheme) {
    currentTheme = newTheme;
    // Re-skin components
    if (_background != null) {
      _background!.removeFromParent();
      _background = BackgroundParallaxComponent(
        worldWidth: currentLevel.boardWidth,
        worldHeight: currentLevel.boardHeight,
        theme: currentTheme,
      );
      world.add(_background!);
    }

    if (_organicBoard != null) {
      _organicBoard!.removeFromParent();
      _organicBoard = OrganicBoardComponent(
        level: currentLevel,
        theme: currentTheme,
        currentSequentialTarget: currentSequentialStep,
      );
      world.add(_organicBoard!);
    }

    if (_liftingBar != null) {
      _liftingBar!.removeFromParent();
      _liftingBar = LiftingBarComponent(
        railLeftX: currentLevel.railLeftX,
        railRightX: currentLevel.railRightX,
        theme: currentTheme,
        initialMidpoint: Vector2(
          (currentLevel.railLeftX + currentLevel.railRightX) / 2.0,
          currentLevel.barStartY,
        ),
        isVibrationEnabled: () => gameService.playerData.vibrationEnabled,
      );
      world.add(_liftingBar!);
    }

    if (_pulleyCables != null) {
      _pulleyCables!.removeFromParent();
      _pulleyCables = PulleyCableComponent(
        liftingBar: _liftingBar!,
        theme: currentTheme,
        railLeftX: currentLevel.railLeftX,
        railRightX: currentLevel.railRightX,
        pulleyY: currentLevel.railTopY,
      );
      world.add(_pulleyCables!);
    }

    if (_marble != null) {
      final curPos = _marble!.body.position.clone();
      _marble!.removeFromParent();
      _marble = MarbleComponent(
        initialPosition: curPos,
        theme: currentTheme,
      );
      world.add(_marble!);
    }
  }

  Future<void> _buildLevel() async {
    // 1. Background void layer
    _background = BackgroundParallaxComponent(
      worldWidth: currentLevel.boardWidth,
      worldHeight: currentLevel.boardHeight,
      theme: currentTheme,
    );
    await world.add(_background!);

    // 2. Cutout Organic Board
    _organicBoard = OrganicBoardComponent(
      level: currentLevel,
      theme: currentTheme,
      currentSequentialTarget: currentSequentialStep,
    );
    await world.add(_organicBoard!);

    // 3. Static Boundary Rails & Base Stops (Prevents marble from rolling off left/right edges)
    _buildRailBoundaries();

    // 4. Kinematic Lifting Bar (Spans railLeftX to railRightX)
    _liftingBar = LiftingBarComponent(
      railLeftX: currentLevel.railLeftX,
      railRightX: currentLevel.railRightX,
      theme: currentTheme,
      initialMidpoint: Vector2(
        (currentLevel.railLeftX + currentLevel.railRightX) / 2.0,
        currentLevel.barStartY,
      ),
      isVibrationEnabled: () => gameService.playerData.vibrationEnabled,
    );
    await world.add(_liftingBar!);

    // 5. Dynamic Pulley Cables
    _pulleyCables = PulleyCableComponent(
      liftingBar: _liftingBar!,
      theme: currentTheme,
      railLeftX: currentLevel.railLeftX,
      railRightX: currentLevel.railRightX,
      pulleyY: currentLevel.railTopY,
    );
    await world.add(_pulleyCables!);

    // 6. Dynamic Marble (Rests directly on the bar)
    _marble = MarbleComponent(
      initialPosition: Vector2(
        currentLevel.marbleStartPos.dx,
        currentLevel.marbleStartPos.dy,
      ),
      theme: currentTheme,
    );
    await world.add(_marble!);

    // Sync bar target positions
    _updateBarFromSliders();
  }

  void _buildRailBoundaries() {
    // Left boundary rail at x = 6.0 (ZERO BOUNCE — solid metallic stop)
    final leftDef = BodyDef(type: BodyType.static, userData: 'rail');
    final leftBody = world.createBody(leftDef);
    final leftShape = EdgeShape()
      ..set(
        Vector2(currentLevel.railLeftX - 0.2, currentLevel.railTopY - 2.0),
        Vector2(currentLevel.railLeftX - 0.2, currentLevel.railBottomY + 2.0),
      );
    leftBody.createFixture(FixtureDef(leftShape, friction: 0.45, restitution: 0.0, userData: 'rail'));
    _railBoundaries.add(leftBody);

    // Right boundary rail at x = 34.0 (ZERO BOUNCE — solid metallic stop)
    final rightDef = BodyDef(type: BodyType.static, userData: 'rail');
    final rightBody = world.createBody(rightDef);
    final rightShape = EdgeShape()
      ..set(
        Vector2(currentLevel.railRightX + 0.2, currentLevel.railTopY - 2.0),
        Vector2(currentLevel.railRightX + 0.2, currentLevel.railBottomY + 2.0),
      );
    rightBody.createFixture(FixtureDef(rightShape, friction: 0.45, restitution: 0.0, userData: 'rail'));
    _railBoundaries.add(rightBody);

    // Top stop bumper (ZERO BOUNCE)
    final topDef = BodyDef(type: BodyType.static, userData: 'top_stop');
    final topBody = world.createBody(topDef);
    final topShape = EdgeShape()
      ..set(
        Vector2(currentLevel.railLeftX - 1.0, currentLevel.railTopY - 1.5),
        Vector2(currentLevel.railRightX + 1.0, currentLevel.railTopY - 1.5),
      );
    topBody.createFixture(FixtureDef(topShape, friction: 0.45, restitution: 0.0, userData: 'top_stop'));
    _railBoundaries.add(topBody);
  }

  Future<void> _clearLevel() async {
    for (final b in _railBoundaries) {
      world.destroyBody(b);
    }
    _railBoundaries.clear();

    _background?.removeFromParent();
    _background = null;

    _organicBoard?.removeFromParent();
    _organicBoard = null;

    _pulleyCables?.removeFromParent();
    _pulleyCables = null;

    _liftingBar?.removeFromParent();
    _liftingBar = null;

    _marble?.removeFromParent();
    _marble = null;
  }

  // --- Multi-Touch Slider Input Controls ---

  /// Set Left Slider normalized height (0.0 = bottom, 1.0 = top)
  void setLeftSliderNormalized(double norm) {
    leftSliderNorm = norm.clamp(0.0, 1.0);
    _updateBarFromSliders();
  }

  /// Set Right Slider normalized height (0.0 = bottom, 1.0 = top)
  void setRightSliderNormalized(double norm) {
    rightSliderNorm = norm.clamp(0.0, 1.0);
    _updateBarFromSliders();
  }

  /// Relative drag adjustment for Left slider
  void adjustLeftSliderDelta(double deltaNorm) {
    setLeftSliderNormalized(leftSliderNorm + (deltaNorm * controlSensitivity));
  }

  /// Relative drag adjustment for Right slider
  void adjustRightSliderDelta(double deltaNorm) {
    setRightSliderNormalized(rightSliderNorm + (deltaNorm * controlSensitivity));
  }

  void _updateBarFromSliders() {
    if (_liftingBar == null) return;

    final startY = currentLevel.barStartY;
    final goalY = currentLevel.barGoalY;

    // Convert 0.0->1.0 to world Y (higher slider = lower Y value)
    final targetLY = startY + (goalY - startY) * leftSliderNorm;
    final targetRY = startY + (goalY - startY) * rightSliderNorm;

    _liftingBar!.setTargetHeights(leftY: targetLY, rightY: targetRY);
  }

  // --- Main Physics Loop & Three-Zone Hole Detection ---

  @override
  void update(double dt) {
    // Clamp dt to max 0.033 (30 FPS minimum floor) to prevent physics catapulting and spiral of death
    final safeDt = dt.clamp(0.001, 0.033);
    super.update(safeDt);

    if (playState != GamePlayState.playing) return;

    // Update timers
    elapsedTime += safeDt;
    attemptElapsedTime += safeDt;
    remainingTime -= safeDt;
    onTimerTick?.call(remainingTime, elapsedTime);
    if (remainingTime <= 0) {
      remainingTime = 0;
      _onTimeUp();
      return;
    }

    // Sample marble trajectory points for Ghost Trail
    if (_marble != null && !_marble!.isFalling && !_isAutoRespawning) {
      _trailSampleTimer += dt;
      if (_trailSampleTimer >= 0.04) {
        _trailSampleTimer = 0.0;
        final curPos = _marble!.body.position.clone();
        if (_currentRunTrail.isEmpty || (_currentRunTrail.last - curPos).length > 0.35) {
          _currentRunTrail.add(curPos);
          if (_currentRunTrail.length > 300) _currentRunTrail.removeAt(0);
        }
      }
    }

    // Keep marble seated on bar when rolling on solid bridges
    _maintainMarbleOnBarPhysics(dt);

    // Three-Zone Organic Cutout Hole Interaction with Edge Tipping Heartbeat
    _checkThreeZoneHoleInteraction(dt);
  }

  void _maintainMarbleOnBarPhysics(double dt) {
    if (_marble == null || _liftingBar == null || _marble!.isFalling) return;

    final bar = _liftingBar!;
    final barBody = bar.body;
    final barAngle = barBody.angle;
    final barPos = barBody.position;
    final marblePos = _marble!.body.position;

    // Transform marble position into the bar's local coordinate frame
    final dx = marblePos.x - barPos.x;
    final dy = marblePos.y - barPos.y;
    final cosA = cos(barAngle);
    final sinA = sin(barAngle);

    // Local coordinates: localX along the bar, localY perpendicular to the bar (pointing downward)
    final localX = dx * cosA + dy * sinA;
    final localY = -dx * sinA + dy * cosA;

    final halfWidth = bar.spanWidth / 2.0;
    const fixtureHalfHeight = 0.9;
    final restLocalY = -fixtureHalfHeight - _marble!.radius;

    // If marble is situated along the span of the bar:
    if (localX.abs() <= halfWidth) {
      // 1. Anti-Launch Constraint:
      // When the lifting bar moves upward and suddenly stops or slows, the marble's upward
      // velocity must NOT exceed the bar's upward velocity at that contact point.
      // In Forge2D, upward velocity is negative.
      final barVelY = bar.verticalVelocityAtX(marblePos.x);
      final marbleVel = _marble!.body.linearVelocity;

      // If the marble is near or on the bar surface:
      if (localY <= restLocalY + 0.35 && localY >= restLocalY - 0.60) {
        if (marbleVel.y < barVelY) {
          _marble!.body.linearVelocity = Vector2(marbleVel.x, barVelY);
        }
      }
    }
  }

  /// Three-Zone Hole Interaction Specification:
  /// 1. Safe Bridge Zone: Marble rolls freely across solid board sections.
  /// 2. Beveled Rim Suction Zone: Subtle edge tension without unfair vacuum.
  /// 3. Drop-In Trigger: Scaled to 80% on hazard holes for fair near-miss clearance.
  void _checkThreeZoneHoleInteraction(double dt) {
    if (_marble == null || _marble!.isFalling || _isAutoRespawning) return;

    // Grace period on level start / revival (0.6s) to allow physics to settle on the bar
    if (attemptElapsedTime < 0.6) return;

    final marblePos = _marble!.body.position;
    final marbleOffset = Offset(marblePos.x, marblePos.y);
    OrganicHole? tippingHole;

    for (final hole in currentLevel.holes) {
      final centroid = hole.centroid;
      final centroidVec = Vector2(centroid.dx, centroid.dy);
      final distToCentroid = (centroidVec - marblePos).length;

      // Scale down hazard hole sensor bounds to 80% of their visual radius
      // so near-misses feel fair and do not trigger false-positive failures
      final innerDropThreshold = hole.isGoal ? (hole.radius * 0.85) : (hole.radius * 0.70);
      final bevelOuterRadius = hole.isGoal ? (hole.radius + _marble!.radius * 0.30) : (hole.radius * 0.82);

      // 3. Drop-In Trigger: Marble commits past inner drop threshold
      if (distToCentroid < innerDropThreshold && hole.containsPoint(marbleOffset)) {
        if (hole.isTaped && !hole.isTapeBroken) {
          // Taped hole shield catches the ball on first pass!
          hole.breakTape();
          _organicBoard?.rebuildCache();
          triggerHaptic(() => HapticFeedback.mediumImpact());
          gameService.audioManager.playTapeCrack();
          continue;
        }
        _triggerHoleDropIn(hole);
        return;
      }

      // 2. Beveled Rim Suction Zone:
      // When ball rolls onto the bevel lip, apply subtle radial tipping suction
      if (distToCentroid < bevelOuterRadius) {
        tippingHole = hole;
        final pullDir = (centroidVec - marblePos).normalized();
        final proximity = 1.0 - ((distToCentroid - innerDropThreshold) / (bevelOuterRadius - innerDropThreshold)).clamp(0.0, 1.0);
        final pullForce = pullDir * (rimSuctionForce * proximity * _marble!.body.mass);
        _marble!.body.applyForce(pullForce);

        // Warning heartbeat vibration on the bevel edge!
        if (elapsedTime - _lastSuctionHapticTime > 0.38) {
          _lastSuctionHapticTime = elapsedTime;
          triggerHaptic(() {
            HapticFeedback.mediumImpact();
            // Double-pulse heartbeat
            Future.delayed(const Duration(milliseconds: 120), () {
              if (gameService.playerData.vibrationEnabled) {
                HapticFeedback.lightImpact();
              }
            });
          });
        }
      }
    }

    _organicBoard?.setActiveEdgeTippingHole(tippingHole);
  }

  void _triggerHoleDropIn(OrganicHole hole) {
    final centroidVec = Vector2(hole.centroid.dx, hole.centroid.dy);

    // Drop-in sound & heavy haptic feedback
    HapticFeedback.heavyImpact();
    gameService.audioManager.playSfx(SoundEffect.fallOut);

    _marble!.fallIntoHole(centroidVec, onComplete: () {
      if (hole.isGoal) {
        _handleGoalSuccess(hole);
      } else {
        _handleHoleFailure(hole);
      }
    });
  }

  void _handleGoalSuccess(OrganicHole hole) {
    // Check if sequential target in "Ice Cold Beer" arcade mode
    if (hole.sequentialOrder == currentSequentialStep &&
        currentSequentialStep < currentLevel.targetSequentialCount) {
      // Advanced to next sequential target
      currentSequentialStep++;
      score += 500;
      gameService.audioManager.playSfx(SoundEffect.checkpoint);
      triggerHaptic(() => HapticFeedback.mediumImpact());

      // Update board sequential visual highlight
      _organicBoard?.updateSequentialTarget(currentSequentialStep);

      // Smoothly lower the lifting bar to the starting resting position
      leftSliderNorm = 0.0;
      rightSliderNorm = 0.0;
      _updateBarFromSliders();

      // Return marble to resting shelf with settling grace period
      attemptElapsedTime = 0.0;
      _marble?.reset(Vector2(
        currentLevel.marbleStartPos.dx,
        currentLevel.barStartY - (_liftingBar!.barThickness / 2.0) - _marble!.radius,
      ));
      return;
    }

    // Final Goal Reached! Level Completed
    playState = GamePlayState.levelCompleted;
    final speedBonus = (remainingTime * 15 * currentLevel.coinMultiplier).round();
    score += (1500 * currentLevel.coinMultiplier).round() + speedBonus;

    // 3-Star Mastery Metagame:
    // 1 Star: Beat the board before time runs out
    // 2 Stars: Under par time (cumulative elapsedTime <= parTimeSeconds)
    // 3 Stars: Flawless Run (0 falls: attempts == 1 AND cumulative elapsedTime <= parTimeSeconds)
    final parTime = currentLevel.parTimeSeconds;
    final isUnderPar = elapsedTime <= parTime;
    final isFlawless = attempts == 1;

    if (isFlawless && isUnderPar) {
      stars = 3;
    } else if (isUnderPar) {
      stars = 2;
    } else {
      stars = 1;
    }

    if (wallBounces == 0) {
      score += 500; // Clean instrument bonus
    }

    // Save Personal Best Ghost Replay
    if (_currentRunTrail.length > 2 &&
        (personalBestGhostTrail == null || personalBestGhostTrail!.isEmpty || isUnderPar)) {
      personalBestGhostTrail = List<Vector2>.from(_currentRunTrail);
      _organicBoard?.setPersonalBestGhostTrail(personalBestGhostTrail);
    }

    gameService.audioManager.playSfx(SoundEffect.victory);

    final coinsAwarded = (15 * currentLevel.coinMultiplier).round() + (stars * 10);

    // Record progress
    gameService.completeLevel(
      levelId: currentLevel.id,
      score: score,
      stars: stars,
      coinsCollected: coinsAwarded,
      completionTime: elapsedTime,
    );

    onGoalReached?.call(stars, score, elapsedTime, wallBounces);
    onStateChanged?.call(playState);

    overlays.add('VictoryModal');
  }

  /// Instant Zero-Load 0.6-Second Chute Respawn with Ghost Trail
  void _handleHoleFailure(OrganicHole hole) {
    if (_isAutoRespawning) return;
    _isAutoRespawning = true;

    // Record ghost trail of the failed run
    if (_currentRunTrail.length > 2) {
      ghostTrail = List<Vector2>.from(_currentRunTrail);
      ghostFallPoint = _marble!.body.position.clone();
      _organicBoard?.setGhostTrail(ghostTrail!, ghostFallPoint);
    }
    _currentRunTrail.clear();
    attempts++;
    wallBounces = 0; // Fresh run attempt
    onHoleFell?.call(hole, attempts);

    // Smoothly lower the lifting bar back to starting resting shelf
    leftSliderNorm = 0.0;
    rightSliderNorm = 0.0;
    _updateBarFromSliders();

    // 0.6-second instant zero-load chute respawn (zero friction, zero modals)
    Future.delayed(const Duration(milliseconds: 600), () {
      _isAutoRespawning = false;
      if (playState != GamePlayState.playing && playState != GamePlayState.menu) return;

      // Chute exit pop sound and tactile haptic
      triggerHaptic(() => HapticFeedback.mediumImpact());
      gameService.audioManager.playSfx(SoundEffect.marbleRoll);

      _marble?.reset(Vector2(
        currentLevel.marbleStartPos.dx,
        currentLevel.barStartY - (_liftingBar!.barThickness / 2.0) - _marble!.radius,
      ));
      attemptElapsedTime = 0.0; // Reset only attempt time so 0.6s grace period applies
    });
  }

  void _onTimeUp() {
    playState = GamePlayState.levelFailed;
    gameService.audioManager.playSfx(SoundEffect.failure);
    overlays.add('FailedModal');
  }

  /// Revive marble on the bar
  void reviveMarble() {
    playState = GamePlayState.playing;
    remainingTime += 20.0;
    attemptElapsedTime = 0.0; // Reset attempt timer so grace period protects revive
    leftSliderNorm = 0.0;
    rightSliderNorm = 0.0;
    _updateBarFromSliders();

    _marble?.reset(Vector2(
      currentLevel.marbleStartPos.dx,
      currentLevel.barStartY - (_liftingBar!.barThickness / 2.0) - 1.35,
    ));

    overlays.remove('FailedModal');
  }

  /// Restart current level
  Future<void> restartLevel() async {
    overlays.remove('FailedModal');
    overlays.remove('VictoryModal');
    overlays.remove('PauseModal');
    await loadLevel(currentLevel.id);
  }

  void pauseGame() {
    if (playState == GamePlayState.playing) {
      playState = GamePlayState.paused;
      overlays.add('PauseModal');
    }
  }

  void resumeGame() {
    if (playState == GamePlayState.paused) {
      playState = GamePlayState.playing;
      overlays.remove('PauseModal');
    }
  }
}
