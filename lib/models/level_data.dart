/// Level data model — defines everything needed to build and play a level.
library;

import 'dart:ui';

/// A single wall segment in the maze.
class WallSegment {
  final Offset start;
  final Offset end;
  final double thickness;
  final bool isHazard;
  final bool isMoving;
  final Offset? moveEnd; // for moving walls
  final double moveSpeed;

  const WallSegment({
    required this.start,
    required this.end,
    this.thickness = 0.25,
    this.isHazard = false,
    this.isMoving = false,
    this.moveEnd,
    this.moveSpeed = 1.0,
  });
}

/// A circular obstacle.
class CircleObstacle {
  final Offset center;
  final double radius;
  final bool isHazard;

  const CircleObstacle({
    required this.center,
    required this.radius,
    this.isHazard = false,
  });
}

/// A collectible coin position.
class CoinPlacement {
  final Offset position;
  final int value;
  final bool isRequired; // for optional objectives

  const CoinPlacement({
    required this.position,
    this.value = 10,
    this.isRequired = false,
  });
}

/// A checkpoint in the maze.
class CheckpointPlacement {
  final Offset position;
  final int order; // activation order

  const CheckpointPlacement({
    required this.position,
    required this.order,
  });
}

/// Star thresholds for a level.
class StarThresholds {
  final int threeStarScore;
  final int twoStarScore;
  final int oneStarScore;
  final double? threeStarTimePercent;
  final double? twoStarTimePercent;

  const StarThresholds({
    required this.threeStarScore,
    required this.twoStarScore,
    required this.oneStarScore,
    this.threeStarTimePercent,
    this.twoStarTimePercent,
  });
}

/// Complete level definition.
class LevelData {
  final int id;
  final String name;
  final String worldId;
  final String themeId;
  final int timerSeconds;
  final Offset startPosition;
  final Offset exitPosition;
  final double exitRadius;
  final List<WallSegment> walls;
  final List<CircleObstacle> circles;
  final List<CoinPlacement> coins;
  final List<CheckpointPlacement> checkpoints;
  final StarThresholds starThresholds;
  final int completionReward;
  final int? unlockRequirement; // level id that must be completed
  final String? objectiveDescription;
  final double boardWidth;
  final double boardHeight;

  const LevelData({
    required this.id,
    required this.name,
    required this.worldId,
    this.themeId = 'neon_aqua',
    this.timerSeconds = 120,
    required this.startPosition,
    required this.exitPosition,
    this.exitRadius = 0.5,
    required this.walls,
    this.circles = const [],
    this.coins = const [],
    this.checkpoints = const [],
    required this.starThresholds,
    this.completionReward = 100,
    this.unlockRequirement,
    this.objectiveDescription,
    this.boardWidth = 8.0,
    this.boardHeight = 12.0,
  });
}
