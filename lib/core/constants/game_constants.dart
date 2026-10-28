/// Central game constants for Balancing Maze.
/// All tunable values live here for easy adjustment.
library;

class GameConstants {
  GameConstants._();

  // -- Physics --
  static const double marbleRadius = 0.35;
  static const double marbleDensity = 2.0;
  static const double marbleFriction = 0.4;
  static const double marbleRestitution = 0.3;
  static const double marbleLinearDamping = 0.5;
  static const double marbleAngularDamping = 0.3;
  static const double marbleMaxSpeed = 8.0;
  static const double gravityY = 15.0;

  // -- Board --
  static const double maxTiltAngle = 0.35; // radians (~20 degrees)
  static const double tiltSpeed = 3.0;
  static const double tiltReturnSpeed = 4.0;
  static const double wallThickness = 0.25;
  static const double boardWidth = 8.0; // Forge2D world units
  static const double boardHeight = 12.0;

  // -- Gameplay --
  static const int defaultTimerSeconds = 120;
  static const int countdownSeconds = 3;
  static const int coinValue = 10;
  static const int levelCompletionBonus = 100;
  static const int starBonus = 50;
  static const int checkpointBonus = 25;
  static const double fallThresholdY = -2.0; // below board = fall

  // -- Scoring --
  static const int threeStarTimePercent = 60; // complete in 60% of time
  static const int twoStarTimePercent = 80;
  static const int oneStarTimePercent = 100;

  // -- Economy --
  static const int startingCoins = 500;
  static const int reviveCost = 100;
  static const int replayRewardPercent = 50; // % of first-time reward on replay

  // -- Visual --
  static const double neonGlowRadius = 4.0;
  static const double particleLifespan = 1.5;
  static const int maxParticles = 100;

  // -- Controls --
  static const double defaultSensitivity = 1.0;
  static const double minSensitivity = 0.3;
  static const double maxSensitivity = 2.0;
}
