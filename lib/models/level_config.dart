/// Data-driven Level Configuration Model — Scalability Pillar 1.
/// Defines clean, serializable level configs with support for standard progression,
/// sequential target modes ("Ice Cold Beer"), timed speed-runs, and daily challenge modifiers.
library;

import 'package:flame/extensions.dart';

enum LevelMode {
  standard,
  sequential, // "Ice Cold Beer" target order
  timed,      // Speed run attack
  dailyChallenge,
}

enum DailyModifier {
  none,
  lowGravity,     // Floaty marble (gravity y = 18.0)
  slipperyIce,    // Reduced friction (friction = 0.20)
  speedRunAttack, // Fast 30s par time + 2x currency
}

extension DailyModifierDetails on DailyModifier {
  String get displayName {
    switch (this) {
      case DailyModifier.lowGravity:
        return 'LOW GRAVITY';
      case DailyModifier.slipperyIce:
        return 'SLIPPERY ICE';
      case DailyModifier.speedRunAttack:
        return 'SPEED RUN 2X';
      case DailyModifier.none:
        return 'STANDARD';
    }
  }

  String get description {
    switch (this) {
      case DailyModifier.lowGravity:
        return 'Marble floats with reduced gravity (18.0). Slow, wide tilts required.';
      case DailyModifier.slipperyIce:
        return 'Zero-friction ice glaze (0.20). Momentum is slippery and hard to stop.';
      case DailyModifier.speedRunAttack:
        return 'Reach the top in under 30 seconds for 2X COIN REWARDS!';
      case DailyModifier.none:
        return 'Standard precision instrument physics.';
    }
  }

  Color get badgeColor {
    switch (this) {
      case DailyModifier.lowGravity:
        return const Color(0xFF00E5FF);
      case DailyModifier.slipperyIce:
        return const Color(0xFF76FF03);
      case DailyModifier.speedRunAttack:
        return const Color(0xFFFF9100);
      case DailyModifier.none:
        return const Color(0xFFB0BEC5);
    }
  }
}

class HoleConfig {
  final String id;
  final String name;
  final Offset centroid;
  final double radius;
  final bool isGoal;
  final int sequentialOrder;
  final bool isTaped;
  bool isTapeBroken;
  final Path Function() pathBuilder;
  final List<Offset> polygonPoints;
  Path? _cachedPath;

  HoleConfig({
    required this.id,
    required this.name,
    required this.centroid,
    required this.radius,
    this.isGoal = false,
    this.sequentialOrder = 0,
    this.isTaped = false,
    this.isTapeBroken = false,
    required this.pathBuilder,
    required this.polygonPoints,
  });

  Path createPath() => _cachedPath ??= pathBuilder();

  void breakTape() {
    isTapeBroken = true;
  }

  void resetTape() {
    if (isTaped) isTapeBroken = false;
  }

  bool containsPoint(Offset pt) {
    final distSq = (pt.dx - centroid.dx) * (pt.dx - centroid.dx) +
        (pt.dy - centroid.dy) * (pt.dy - centroid.dy);
    if (distSq > (radius * 1.15) * (radius * 1.15)) return false;
    return createPath().contains(pt);
  }

  double distanceTo(Vector2 point) {
    return (Vector2(centroid.dx, centroid.dy) - point).length;
  }
}

class LevelConfig {
  final int levelId;
  final String boardName;
  final String description;
  final String themeId;
  final LevelMode mode;
  final DailyModifier modifier;
  final double gravityY;
  final double surfaceFriction;
  final double coinMultiplier;
  final double parTimeSeconds;
  final int targetScore;
  final int targetSequentialCount;
  final double boardWidth;
  final double boardHeight;
  final double railLeftX;
  final double railRightX;
  final double railTopY;
  final double railBottomY;
  final double barStartY;
  final double barGoalY;
  final Offset marbleStartPos;
  final List<HoleConfig> holes;
  final List<Offset> ghostPathHints;

  const LevelConfig({
    required this.levelId,
    required this.boardName,
    required this.description,
    required this.themeId,
    this.mode = LevelMode.standard,
    this.modifier = DailyModifier.none,
    this.gravityY = 35.0,
    this.surfaceFriction = 0.50,
    this.coinMultiplier = 1.0,
    this.parTimeSeconds = 60.0,
    this.targetScore = 1500,
    this.targetSequentialCount = 1,
    this.boardWidth = 40.0,
    this.boardHeight = 75.0,
    this.railLeftX = 6.0,
    this.railRightX = 34.0,
    this.railTopY = 12.0,
    this.railBottomY = 64.0,
    this.barStartY = 48.0,
    this.barGoalY = 17.5,
    this.marbleStartPos = const Offset(14.0, 45.95),
    required this.holes,
    this.ghostPathHints = const [],
  });

  HoleConfig? getGoalHole() {
    try {
      return holes.firstWhere((h) => h.isGoal && h.sequentialOrder <= 1);
    } catch (_) {
      return null;
    }
  }

  HoleConfig? getSequentialTarget(int step) {
    try {
      return holes.firstWhere((h) => h.isGoal && h.sequentialOrder == step);
    } catch (_) {
      return null;
    }
  }
}
