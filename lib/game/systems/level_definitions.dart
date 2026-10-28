/// Organic hole and level specifications for Balancing Maze.
/// Defines closed cubic Bezier curves for organic cutouts (kidneys, amoebas, teardrops)
/// and sequential goals for "Ice Cold Beer" arcade progression.
library;

import 'dart:math';
import 'dart:typed_data';
import 'package:flame/extensions.dart';
import '../../models/level_config.dart';

class OrganicHole {
  final String id;
  final String name;
  final Offset centroid;
  final double radius; // effective radius for rim suction
  final bool isGoal;
  final int sequentialOrder; // 0 = hazard, 1,2,3 = sequential targets
  final bool isTaped; // Temporary transparent masking tape shield
  bool isTapeBroken;
  final Path Function() pathBuilder;
  final List<Offset> polygonPoints; // for fast distance checks
  Path? _cachedPath;
  Path? _cachedSensorPath;

  OrganicHole({
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

  /// Sensor collision bounds scaled to 80% for hazard holes
  /// Ensures near-misses feel fair and do not trigger false-positive drops
  Path getSensorPath() {
    if (_cachedSensorPath != null) return _cachedSensorPath!;
    final visual = createPath();
    final matrix = Float64List.fromList([
      0.80, 0.0, 0.0, 0.0,
      0.0, 0.80, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      centroid.dx * 0.20, centroid.dy * 0.20, 0.0, 1.0,
    ]);
    return _cachedSensorPath = visual.transform(matrix);
  }

  void breakTape() {
    isTapeBroken = true;
  }

  void resetTape() {
    if (isTaped) isTapeBroken = false;
  }

  /// Check if a world point is inside this cutout hole sensor
  bool containsPoint(Offset pt, {bool useHazardSensor = true}) {
    // For non-goal hazard cutouts, scale collision bounds down to 80%
    // so near-misses feel fair and do not trigger false-positive failures
    final effectiveRadius = (isGoal || !useHazardSensor) ? radius : (radius * 0.80);

    // Fast bounding box check first
    final distSq = (pt.dx - centroid.dx) * (pt.dx - centroid.dx) +
        (pt.dy - centroid.dy) * (pt.dy - centroid.dy);
    if (distSq > effectiveRadius * effectiveRadius) return false;

    // Accurate Path containment check
    if (isGoal || !useHazardSensor) {
      return createPath().contains(pt);
    }
    return getSensorPath().contains(pt);
  }

  /// Distance from a world point to the centroid
  double distanceTo(Vector2 point) {
    return (Vector2(centroid.dx, centroid.dy) - point).length;
  }
}

class BoardLevel {
  final int id;
  final String title;
  final String modeName; // "Taped Mode", "Arcade Sequential", "Master Organic"
  final String description;
  final String lessonObjective;
  final String skillBrief;
  final String themeId;
  final LevelMode mode;
  final DailyModifier modifier;
  final double gravityY;
  final double surfaceFriction;
  final double coinMultiplier;
  final double parTimeSeconds;
  final double boardWidth;
  final double boardHeight;
  final double railLeftX;
  final double railRightX;
  final double railTopY;
  final double railBottomY;
  final double barStartY;
  final double barGoalY;
  final Offset marbleStartPos;
  final List<OrganicHole> holes;
  final List<Offset> ghostPathHints;
  final int targetSequentialCount;
  final int targetScore;
  final int timerSeconds;

  const BoardLevel({
    required this.id,
    required this.title,
    required this.modeName,
    required this.description,
    this.lessonObjective = '',
    this.skillBrief = '',
    required this.themeId,
    this.mode = LevelMode.standard,
    this.modifier = DailyModifier.none,
    this.gravityY = 35.0,
    this.surfaceFriction = 0.50,
    this.coinMultiplier = 1.0,
    double? parTimeSeconds,
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
    this.targetSequentialCount = 1,
    this.targetScore = 1500,
    this.timerSeconds = 120,
  }) : parTimeSeconds = parTimeSeconds ?? (timerSeconds * 0.55);

  BoardLevel copyWith({
    int? id,
    String? title,
    String? modeName,
    String? description,
    String? lessonObjective,
    String? skillBrief,
    String? themeId,
    LevelMode? mode,
    DailyModifier? modifier,
    double? gravityY,
    double? surfaceFriction,
    double? coinMultiplier,
    double? parTimeSeconds,
    double? boardWidth,
    double? boardHeight,
    double? railLeftX,
    double? railRightX,
    double? railTopY,
    double? railBottomY,
    double? barStartY,
    double? barGoalY,
    Offset? marbleStartPos,
    List<OrganicHole>? holes,
    List<Offset>? ghostPathHints,
    int? targetSequentialCount,
    int? targetScore,
    int? timerSeconds,
  }) {
    return BoardLevel(
      id: id ?? this.id,
      title: title ?? this.title,
      modeName: modeName ?? this.modeName,
      description: description ?? this.description,
      lessonObjective: lessonObjective ?? this.lessonObjective,
      skillBrief: skillBrief ?? this.skillBrief,
      themeId: themeId ?? this.themeId,
      mode: mode ?? this.mode,
      modifier: modifier ?? this.modifier,
      gravityY: gravityY ?? this.gravityY,
      surfaceFriction: surfaceFriction ?? this.surfaceFriction,
      coinMultiplier: coinMultiplier ?? this.coinMultiplier,
      parTimeSeconds: parTimeSeconds ?? this.parTimeSeconds,
      boardWidth: boardWidth ?? this.boardWidth,
      boardHeight: boardHeight ?? this.boardHeight,
      railLeftX: railLeftX ?? this.railLeftX,
      railRightX: railRightX ?? this.railRightX,
      railTopY: railTopY ?? this.railTopY,
      railBottomY: railBottomY ?? this.railBottomY,
      barStartY: barStartY ?? this.barStartY,
      barGoalY: barGoalY ?? this.barGoalY,
      marbleStartPos: marbleStartPos ?? this.marbleStartPos,
      holes: holes ?? this.holes,
      ghostPathHints: ghostPathHints ?? this.ghostPathHints,
      targetSequentialCount: targetSequentialCount ?? this.targetSequentialCount,
      targetScore: targetScore ?? this.targetScore,
      timerSeconds: timerSeconds ?? this.timerSeconds,
    );
  }

  OrganicHole? getGoalHole() {
    try {
      return holes.firstWhere((h) => h.isGoal && h.sequentialOrder <= 1);
    } catch (_) {
      return null;
    }
  }

  OrganicHole? getSequentialTarget(int step) {
    try {
      return holes.firstWhere((h) => h.isGoal && h.sequentialOrder == step);
    } catch (_) {
      return null;
    }
  }
}

/// Deterministic Daily Challenge Generator — Rotates daily modifiers every 24h
class DailyChallengeService {
  DailyChallengeService._();

  static BoardLevel getTodaysChallenge([DateTime? date]) {
    final now = date ?? DateTime.now();
    final dayIndex = (now.year * 365 + now.month * 31 + now.day);
    final modIndex = dayIndex % 3;

    DailyModifier modifier;
    double grav;
    double fric;
    double coinMult;
    int parSeconds;
    String modeDesc;

    switch (modIndex) {
      case 0:
        modifier = DailyModifier.lowGravity;
        grav = 18.0; // Floaty low gravity
        fric = 0.50;
        coinMult = 1.5;
        parSeconds = 75;
        modeDesc = 'Low Gravity Day: Floaty marble (18.0)! Gentle, wide tilts required.';
        break;
      case 1:
        modifier = DailyModifier.slipperyIce;
        grav = 35.0;
        fric = 0.20; // Reduced surface friction
        coinMult = 1.5;
        parSeconds = 75;
        modeDesc = 'Slippery Ice Mode: Halved friction (0.20)! Master micro-stalling!';
        break;
      case 2:
      default:
        modifier = DailyModifier.speedRunAttack;
        grav = 35.0;
        fric = 0.50;
        coinMult = 2.0; // 2x currency bonus
        parSeconds = 30; // 30-second par time
        modeDesc = 'Speed Run Attack: Reach the top goal in under 30s for 2X COINS!';
        break;
    }

    final base = LevelDefinitions.level4MasterOrganic;
    return base.copyWith(
      id: 999, // Special Daily Challenge ID
      title: 'DAILY CHALLENGE',
      modeName: modifier.displayName,
      description: modeDesc,
      mode: LevelMode.dailyChallenge,
      modifier: modifier,
      gravityY: grav,
      surfaceFriction: fric,
      coinMultiplier: coinMult,
      parTimeSeconds: parSeconds.toDouble(),
      timerSeconds: parSeconds + 20,
      targetScore: (base.targetScore * coinMult).round(),
    );
  }
}

class LevelDefinitions {
  LevelDefinitions._();

  // =========================================================================
  // ORGANIC CUTOUT SHAPE BUILDERS (Cubic Bezier Paths matching Reference 1 & 2)
  // =========================================================================

  /// 1. Top Central Goal Cup (Circular Cup with Chevron Arrow)
  static OrganicHole buildTopGoalCup({
    required String id,
    Offset center = const Offset(20.0, 17.5),
    double r = 2.3,
    int order = 1,
  }) {
    return OrganicHole(
      id: id,
      name: 'Top Goal Cup',
      centroid: center,
      radius: r,
      isGoal: true,
      sequentialOrder: order,
      pathBuilder: () {
        return Path()
          ..addOval(Rect.fromCircle(center: center, radius: r));
      },
      polygonPoints: _generateCirclePoints(center, r, 16),
    );
  }

  /// 2. Upper-Left Triangle-Kidney Cutout (Y: ~21.0..29.5)
  static OrganicHole buildUpperLeftKidney() {
    const center = Offset(13.0, 24.5);
    return OrganicHole(
      id: 'upper_left_kidney',
      name: 'Upper-Left Kidney',
      centroid: center,
      radius: 4.0,
      isGoal: false,
      pathBuilder: () {
        final path = Path();
        path.moveTo(10.0, 21.0);
        path.cubicTo(13.5, 19.5, 16.5, 20.5, 16.5, 23.5);
        path.cubicTo(16.5, 26.5, 14.5, 28.0, 15.5, 29.5);
        path.cubicTo(14.0, 31.0, 11.0, 30.5, 9.5, 28.5);
        path.cubicTo(8.0, 25.5, 8.5, 22.5, 10.0, 21.0);
        path.close();
        return path;
      },
      polygonPoints: const [
        Offset(10.0, 21.0),
        Offset(15.0, 20.0),
        Offset(16.5, 24.5),
        Offset(15.5, 29.5),
        Offset(11.0, 30.5),
        Offset(8.5, 25.5),
      ],
    );
  }

  /// 3. Upper-Center Diagonal Oval Cutout (Y: ~23.5..30.5)
  static OrganicHole buildUpperCenterOval() {
    const center = Offset(21.5, 26.5);
    return OrganicHole(
      id: 'upper_center_oval',
      name: 'Upper-Center Oval',
      centroid: center,
      radius: 4.2,
      isGoal: false,
      pathBuilder: () {
        final path = Path();
        path.moveTo(17.0, 27.5);
        path.cubicTo(15.5, 24.5, 20.5, 22.5, 24.5, 24.0);
        path.cubicTo(28.0, 25.5, 27.5, 29.0, 24.5, 30.5);
        path.cubicTo(21.0, 31.5, 18.0, 30.5, 17.0, 27.5);
        path.close();
        return path;
      },
      polygonPoints: const [
        Offset(17.0, 27.5),
        Offset(20.0, 23.0),
        Offset(26.0, 24.5),
        Offset(27.5, 29.0),
        Offset(23.0, 31.0),
        Offset(18.0, 30.0),
      ],
    );
  }

  /// 4. Upper-Right Elongated Kidney Cutout (Y: ~21.0..30.5)
  static OrganicHole buildUpperRightKidney() {
    const center = Offset(29.0, 25.0);
    return OrganicHole(
      id: 'upper_right_kidney',
      name: 'Upper-Right Kidney',
      centroid: center,
      radius: 4.2,
      isGoal: false,
      pathBuilder: () {
        final path = Path();
        path.moveTo(27.0, 21.0);
        path.cubicTo(31.0, 20.0, 33.0, 22.5, 32.5, 26.5);
        path.cubicTo(32.0, 30.0, 30.0, 32.0, 27.5, 32.5);
        path.cubicTo(25.5, 32.5, 25.0, 30.5, 26.0, 28.0);
        path.cubicTo(27.0, 25.5, 25.5, 23.5, 25.5, 22.5);
        path.close();
        return path;
      },
      polygonPoints: const [
        Offset(27.0, 21.0),
        Offset(32.0, 21.0),
        Offset(32.5, 26.5),
        Offset(29.0, 32.5),
        Offset(25.5, 29.5),
        Offset(25.5, 23.0),
      ],
    );
  }

  /// 5. Mid-Left Large Amoeba Cutout (Y: ~31.0..39.2)
  static OrganicHole buildMidLeftAmoeba({bool isTaped = false}) {
    const center = Offset(13.5, 35.0);
    return OrganicHole(
      id: 'mid_left_amoeba',
      name: 'Mid-Left Amoeba',
      centroid: center,
      radius: 4.0,
      isGoal: false,
      isTaped: isTaped,
      pathBuilder: () {
        final path = Path();
        path.moveTo(9.5, 31.5);
        path.cubicTo(14.0, 30.0, 17.5, 31.5, 17.5, 34.5);
        path.cubicTo(17.5, 37.0, 15.5, 38.0, 14.5, 38.8);
        path.cubicTo(13.5, 39.2, 11.5, 39.2, 10.0, 38.0);
        path.cubicTo(8.0, 36.5, 8.0, 34.0, 9.5, 31.5);
        path.close();
        return path;
      },
      polygonPoints: const [
        Offset(9.5, 31.5),
        Offset(16.0, 30.5),
        Offset(17.5, 34.5),
        Offset(14.5, 38.8),
        Offset(10.5, 39.2),
        Offset(8.0, 36.0),
      ],
    );
  }

  /// 6. Mid-Center L-Kidney Cutout (Y: ~31.5..39.2)
  static OrganicHole buildMidCenterLKidney() {
    const center = Offset(26.0, 35.0);
    return OrganicHole(
      id: 'mid_center_l_kidney',
      name: 'Mid-Center L-Kidney',
      centroid: center,
      radius: 4.0,
      isGoal: false,
      pathBuilder: () {
        final path = Path();
        path.moveTo(22.5, 32.0);
        path.cubicTo(26.0, 31.0, 28.0, 32.0, 29.0, 34.5);
        path.cubicTo(30.0, 36.5, 31.0, 37.5, 30.5, 38.8);
        path.cubicTo(29.5, 39.2, 27.0, 39.2, 25.0, 38.5);
        path.cubicTo(23.5, 37.0, 22.0, 35.5, 21.0, 33.5);
        path.close();
        return path;
      },
      polygonPoints: const [
        Offset(22.5, 32.0),
        Offset(28.0, 31.5),
        Offset(30.5, 35.0),
        Offset(30.5, 38.8),
        Offset(26.0, 39.2),
        Offset(21.5, 35.0),
      ],
    );
  }

  /// 7. Lower-Center Vertical Teardrop Cutout (Y: ~32.0..39.2)
  static OrganicHole buildLowerCenterTeardrop() {
    const center = Offset(19.5, 35.5);
    return OrganicHole(
      id: 'lower_center_teardrop',
      name: 'Lower-Center Teardrop',
      centroid: center,
      radius: 3.5,
      isGoal: false,
      pathBuilder: () {
        final path = Path();
        path.moveTo(19.5, 32.0);
        path.cubicTo(22.0, 32.5, 23.0, 34.5, 22.5, 36.5);
        path.cubicTo(22.0, 38.2, 20.5, 39.2, 19.5, 39.2);
        path.cubicTo(18.0, 39.2, 17.0, 38.2, 17.0, 36.5);
        path.cubicTo(17.0, 34.5, 17.5, 32.5, 19.5, 32.0);
        path.close();
        return path;
      },
      polygonPoints: const [
        Offset(19.5, 32.0),
        Offset(22.5, 34.0),
        Offset(22.5, 37.5),
        Offset(19.5, 39.2),
        Offset(17.0, 37.5),
        Offset(17.5, 34.0),
      ],
    );
  }

  /// 8. Lower-Left Pocket Cutout (Y: ~55.0..62.5 — well below the starting bar)
  static OrganicHole buildLowerLeftPocket() {
    const center = Offset(13.0, 58.5);
    return OrganicHole(
      id: 'lower_left_pocket',
      name: 'Lower-Left Pocket',
      centroid: center,
      radius: 3.5,
      isGoal: false,
      pathBuilder: () {
        final path = Path();
        path.moveTo(10.5, 56.0);
        path.cubicTo(13.5, 55.0, 16.0, 56.0, 16.0, 58.5);
        path.cubicTo(16.0, 61.0, 14.0, 62.5, 11.5, 62.0);
        path.cubicTo(9.5, 61.5, 9.0, 59.0, 10.5, 56.0);
        path.close();
        return path;
      },
      polygonPoints: const [
        Offset(10.5, 56.0),
        Offset(15.0, 55.0),
        Offset(16.0, 58.5),
        Offset(13.0, 62.0),
        Offset(9.5, 60.5),
      ],
    );
  }

  /// 9. Lower-Right Heart-Kidney Cutout (Y: ~55.0..62.5 — well below the starting bar)
  static OrganicHole buildLowerRightHeartKidney() {
    const center = Offset(28.0, 58.5);
    return OrganicHole(
      id: 'lower_right_heart_kidney',
      name: 'Lower-Right Heart',
      centroid: center,
      radius: 3.5,
      isGoal: false,
      pathBuilder: () {
        final path = Path();
        path.moveTo(25.5, 56.0);
        path.cubicTo(28.5, 55.0, 31.5, 56.0, 32.0, 58.5);
        path.cubicTo(32.5, 61.0, 30.0, 62.5, 27.5, 62.0);
        path.cubicTo(25.0, 61.5, 24.5, 59.0, 25.5, 56.0);
        path.close();
        return path;
      },
      polygonPoints: const [
        Offset(25.5, 56.0),
        Offset(30.0, 55.0),
        Offset(32.0, 58.5),
        Offset(29.0, 62.0),
        Offset(25.0, 60.5),
      ],
    );
  }

  // =========================================================================
  // LEVELS 1 TO 6 PROGRESSION
  // =========================================================================

  /// Level 1: "FIRST ROLL" — The Basics (Lift & Horizontal Roll)
  /// Design Brief: "This level teaches the player to lift both sides smoothly and tilt gently to roll, and tests it by reaching the wide goal cup."
  /// 1. New skill: Coordinated dual-slider lift & horizontal tilt.
  /// 2. What player sees: Wide starting bar, clear board with 3 transparent taped shields, wide goal cup.
  /// 3. Main decision: Balancing tilt angle to maintain controlled roll speed.
  /// 4. Failure cost: Taped holes protect against falling in; generous 150s timer.
  /// 5. Mastery test: Smooth roll into the goal cup under 35s.
  static final level1Training = BoardLevel(
    id: 1,
    title: 'LEVEL 01',
    modeName: 'FIRST ROLL',
    description: 'Master the dual lifting controls and gentle tilts across wide forgiving bridges.',
    lessonObjective: 'Lift both sides smoothly and tilt gently to roll',
    skillBrief: 'Learn bar lift & horizontal roll control with taped safety shields',
    themeId: 'classic_cyan',
    targetScore: 1000,
    timerSeconds: 150,
    parTimeSeconds: 35.0,
    barStartY: 48.0,
    barGoalY: 17.5,
    marbleStartPos: const Offset(14.0, 45.95),
    holes: [
      buildTopGoalCup(id: 'goal_01', center: const Offset(20.0, 17.5), r: 2.5),
      OrganicHole(
        id: 'tape_hole_1',
        name: 'Lower Taped Trap',
        centroid: const Offset(15.0, 38.0),
        radius: 2.2,
        isTaped: true,
        pathBuilder: () => Path()..addOval(Rect.fromCircle(center: const Offset(15.0, 38.0), radius: 2.2)),
        polygonPoints: _generateCirclePoints(const Offset(15.0, 38.0), 2.2, 12),
      ),
      OrganicHole(
        id: 'tape_hole_2',
        name: 'Mid Right Taped Trap',
        centroid: const Offset(26.0, 32.0),
        radius: 2.3,
        isTaped: true,
        pathBuilder: () => Path()..addOval(Rect.fromCircle(center: const Offset(26.0, 32.0), radius: 2.3)),
        polygonPoints: _generateCirclePoints(const Offset(26.0, 32.0), 2.3, 12),
      ),
      OrganicHole(
        id: 'tape_hole_3',
        name: 'Upper Left Taped Trap',
        centroid: const Offset(14.0, 24.0),
        radius: 2.2,
        isTaped: true,
        pathBuilder: () => Path()..addOval(Rect.fromCircle(center: const Offset(14.0, 24.0), radius: 2.2)),
        polygonPoints: _generateCirclePoints(const Offset(14.0, 24.0), 2.2, 12),
      ),
    ],
    ghostPathHints: const [
      Offset(14.0, 46.0),
      Offset(24.0, 38.0),
      Offset(16.0, 32.0),
      Offset(24.0, 24.0),
      Offset(20.0, 17.5),
    ],
  );

  /// Level 2: "BRAKE POINT" — Counter-Tilting to Decelerate
  /// Design Brief: "This level teaches the player to counter-tilt to brake, and tests it by stopping safely before a central cutout."
  /// 1. New skill: Counter-tilt to brake.
  /// 2. What player sees: A wide stopping plateau before a central gap (Teardrop), with safe detours.
  /// 3. Main decision: When to stop accelerating and begin counter-tilting before the drop.
  /// 4. Failure cost: Quick respawn at the starting shelf if the marble drops into the teardrop.
  /// 5. Mastery test: Smoothly brake and dock into the goal cup under 40s.
  static final level2Arcade = BoardLevel(
    id: 2,
    title: 'LEVEL 02',
    modeName: 'BRAKE POINT',
    description: 'Accelerate across the lower shelf, then counter-tilt to brake before the central drop.',
    lessonObjective: 'Tilt the bar opposite the roll direction to brake',
    skillBrief: 'Counter-tilt braking before approaching open cutouts',
    themeId: 'classic_cyan',
    targetScore: 2000,
    timerSeconds: 120,
    parTimeSeconds: 40.0,
    barStartY: 48.0,
    barGoalY: 17.5,
    marbleStartPos: const Offset(14.0, 45.95),
    holes: [
      buildTopGoalCup(id: 'goal_02', center: const Offset(20.0, 17.5), r: 2.4),
      buildLowerCenterTeardrop(),
      buildUpperCenterOval(),
    ],
    ghostPathHints: const [
      Offset(14.0, 46.0),
      Offset(28.0, 42.0),
      Offset(26.0, 35.0),
      Offset(14.0, 26.0),
      Offset(20.0, 17.5),
    ],
  );

  /// Level 3: "MIND THE GAP" — Lateral Detours & Corridor Selection
  /// Design Brief: "This level teaches the player to steer laterally around central hazards, and tests it by choosing a safe detour."
  /// 1. New skill: Lateral bypass while maintaining bar elevation.
  /// 2. What player sees: Centered Teardrop and L-Kidney forming a corridor fork (left vs right).
  /// 3. Main decision: Take the wider left detour or the faster, tighter right corridor.
  /// 4. Failure cost: Rim suction drop into kidney cutout.
  /// 5. Mastery test: Clean passage without striking side rails or falling.
  static final level3Steampunk = BoardLevel(
    id: 3,
    title: 'LEVEL 03',
    modeName: 'MIND THE GAP',
    description: 'Thread past central hazards by choosing between the wide left flank and tight right corridor.',
    lessonObjective: 'Steer laterally around central hazards while ascending',
    skillBrief: 'Lateral hazard detour & corridor navigation',
    themeId: 'steampunk_brass',
    targetScore: 3000,
    timerSeconds: 110,
    parTimeSeconds: 45.0,
    barStartY: 48.0,
    barGoalY: 17.5,
    marbleStartPos: const Offset(14.0, 45.95),
    holes: [
      buildTopGoalCup(id: 'goal_03', center: const Offset(20.0, 17.5), r: 2.3),
      buildLowerCenterTeardrop(),
      buildMidCenterLKidney(),
      buildUpperLeftKidney(),
      buildUpperRightKidney(),
    ],
    ghostPathHints: const [
      Offset(14.0, 46.0),
      Offset(11.0, 37.0),
      Offset(15.0, 28.0),
      Offset(20.0, 17.5),
    ],
  );

  /// Level 4: "THE S-CURVE" — Rhythmic Slalom Steering (Master Organic Reference)
  /// Design Brief: "This level teaches rhythmic left-right balancing, and tests it through a winding chicane."
  /// 1. New skill: Slalom balance: continuous rhythmic left-to-right counter-tilts.
  /// 2. What player sees: The iconic 9 organic cutouts forming an S-shaped navigation channel.
  /// 3. Main decision: Timing the reversal of tilt direction at each apex of the chicane.
  /// 4. Failure cost: Fall into any organic cutout rim.
  /// 5. Mastery test: Flowing through the chicane without stopping or bouncing off outer walls.
  static final level4MasterOrganic = BoardLevel(
    id: 4,
    title: 'LEVEL 04',
    modeName: 'THE S-CURVE',
    description: 'Weave through the iconic 9 organic cutouts using rhythmic counter-tilts.',
    lessonObjective: 'Rhythmically alternate tilt left and right through the chicane',
    skillBrief: 'Slalom balance: continuous coordinated left-right transitions',
    themeId: 'classic_cyan',
    targetScore: 4500,
    timerSeconds: 100,
    parTimeSeconds: 48.0,
    barStartY: 48.0,
    barGoalY: 17.5,
    marbleStartPos: const Offset(14.0, 45.95),
    holes: [
      // 1. Top Goal Cup
      buildTopGoalCup(id: 'master_goal', center: const Offset(20.0, 17.5), r: 2.3),
      // 2. Upper-Left Triangle-Kidney
      buildUpperLeftKidney(),
      // 3. Upper-Center Diagonal Oval
      buildUpperCenterOval(),
      // 4. Upper-Right Elongated Kidney
      buildUpperRightKidney(),
      // 5. Mid-Left Large Amoeba
      buildMidLeftAmoeba(),
      // 6. Mid-Center L-Kidney
      buildMidCenterLKidney(),
      // 7. Lower-Center Vertical Teardrop
      buildLowerCenterTeardrop(),
      // 8. Lower-Left Pocket
      buildLowerLeftPocket(),
      // 9. Lower-Right Heart-Kidney
      buildLowerRightHeartKidney(),
    ],
    ghostPathHints: const [
      Offset(14.0, 46.0),
      Offset(26.0, 42.0),
      Offset(18.0, 36.0),
      Offset(25.0, 30.0),
      Offset(15.0, 24.0),
      Offset(20.0, 17.5),
    ],
  );

  /// Level 5: "RISK & REWARD" — Strategic Route Planning & Breakable Shields
  /// Design Brief: "This level teaches deliberate route planning, and tests it by offering a safe perimeter route versus a breakable tape shortcut."
  /// 1. New skill: Route risk assessment & committing to breakable tape shields at speed.
  /// 2. What player sees: High-voltage neon board with 2 temporary taped shields on the express line.
  /// 3. Main decision: Take the slow safe perimeter, or blast across the tape shield shortcut.
  /// 4. Failure cost: Tape breaks after 1 roll; returning backwards results in immediate drop.
  /// 5. Mastery test: Speed-run across both taped shields straight into the goal under 42s.
  static final level5Cyberpunk = BoardLevel(
    id: 5,
    title: 'LEVEL 05',
    modeName: 'RISK & REWARD',
    description: 'High-voltage neon corridors with 2 breakable tape shields guarding the express path.',
    lessonObjective: 'Choose between a safe outer detour and a fast shielded shortcut',
    skillBrief: 'Route planning: safe outer line vs fast breakable-tape shortcut',
    themeId: 'cyberpunk_neon',
    targetScore: 5000,
    timerSeconds: 90,
    parTimeSeconds: 42.0,
    barStartY: 48.0,
    barGoalY: 17.5,
    marbleStartPos: const Offset(14.0, 45.95),
    holes: [
      buildTopGoalCup(id: 'cyber_goal', center: const Offset(20.0, 17.5), r: 2.3),
      buildUpperLeftKidney(),
      buildUpperCenterOval(),
      // Strategic Taped Shield 1 in upper-right corridor
      OrganicHole(
        id: 'cyber_tape_1',
        name: 'Upper Cyber Shield',
        centroid: const Offset(28.0, 24.5),
        radius: 2.4,
        isTaped: true,
        pathBuilder: () => Path()..addOval(Rect.fromCircle(center: const Offset(28.0, 24.5), radius: 2.4)),
        polygonPoints: _generateCirclePoints(const Offset(28.0, 24.5), 2.4, 12),
      ),
      buildMidLeftAmoeba(),
      // Strategic Taped Shield 2 in mid-right corridor
      OrganicHole(
        id: 'cyber_tape_2',
        name: 'Mid Cyber Shield',
        centroid: const Offset(26.5, 34.5),
        radius: 2.4,
        isTaped: true,
        pathBuilder: () => Path()..addOval(Rect.fromCircle(center: const Offset(26.5, 34.5), radius: 2.4)),
        polygonPoints: _generateCirclePoints(const Offset(26.5, 34.5), 2.4, 12),
      ),
      buildLowerCenterTeardrop(),
      buildLowerLeftPocket(),
      buildLowerRightHeartKidney(),
    ],
    ghostPathHints: const [
      Offset(14.0, 46.0),
      Offset(26.5, 34.5),
      Offset(28.0, 24.5),
      Offset(20.0, 17.5),
    ],
  );

  /// Level 6: "MASTER GAUNTLET" — Full Synthesis Challenge
  /// Design Brief: "This level tests total board mastery, combining braking, slalom steering, and precision docking across all hazards."
  /// 1. New skill: Flawless synthesis of braking, slalom, and precision docking under tight tolerances.
  /// 2. What player sees: Tight bamboo rails, 10 cutouts including a mid vine trap, smaller altar goal cup.
  /// 3. Main decision: Precise speed modulation at each elevation step.
  /// 4. Failure cost: High — tightest goal tolerance (r = 2.15).
  /// 5. Mastery test: Flawless run under 40s to earn the Master 3-star trophy.
  static final level6Jungle = BoardLevel(
    id: 6,
    title: 'LEVEL 06',
    modeName: 'MASTER GAUNTLET',
    description: 'The ultimate synthesis: tight bamboo rails and narrow approach angles to the ceremonial goal.',
    lessonObjective: 'Synthesize braking, slalom, and precision docking under pressure',
    skillBrief: 'Master synthesis: 9-cutout labyrinth with precision docking',
    themeId: 'jungle_bamboo',
    targetScore: 6000,
    timerSeconds: 85,
    parTimeSeconds: 40.0,
    barStartY: 48.0,
    barGoalY: 17.5,
    marbleStartPos: const Offset(14.0, 45.95),
    holes: [
      buildTopGoalCup(id: 'jungle_goal', center: const Offset(20.0, 17.5), r: 2.15),
      buildUpperLeftKidney(),
      buildUpperCenterOval(),
      buildUpperRightKidney(),
      buildMidLeftAmoeba(),
      buildMidCenterLKidney(),
      buildLowerCenterTeardrop(),
      // Mid Vine Trap creating a central S-curve requirement
      OrganicHole(
        id: 'jungle_vine_trap',
        name: 'Mid Vine Trap',
        centroid: const Offset(20.0, 29.5),
        radius: 2.2,
        isGoal: false,
        pathBuilder: () => Path()..addOval(Rect.fromCircle(center: const Offset(20.0, 29.5), radius: 2.2)),
        polygonPoints: _generateCirclePoints(const Offset(20.0, 29.5), 2.2, 12),
      ),
      buildLowerLeftPocket(),
      buildLowerRightHeartKidney(),
    ],
    ghostPathHints: const [
      Offset(14.0, 46.0),
      Offset(26.0, 42.0),
      Offset(13.0, 36.0),
      Offset(27.0, 27.0),
      Offset(20.0, 17.5),
    ],
  );

  static final List<BoardLevel> allLevels = [
    level1Training,
    level2Arcade,
    level3Steampunk,
    level4MasterOrganic,
    level5Cyberpunk,
    level6Jungle,
  ];

  static bool hasLevel(int id) {
    return id == 999 || allLevels.any((l) => l.id == id);
  }

  static BoardLevel? tryGetById(int id) {
    if (id == 999) return DailyChallengeService.getTodaysChallenge();
    final idx = allLevels.indexWhere((l) => l.id == id);
    if (idx != -1) return allLevels[idx];
    return null;
  }

  static BoardLevel getById(int id) {
    final level = tryGetById(id);
    if (level != null) return level;
    throw ArgumentError(
      'Level $id does not exist. Handcrafted playable levels are 1 through ${allLevels.length}.',
    );
  }

  static BoardLevel getLevel(int id) => getById(id);

  static List<Offset> _generateCirclePoints(Offset center, double radius, int segments) {
    final points = <Offset>[];
    for (int i = 0; i < segments; i++) {
      final angle = (i * 2 * pi) / segments;
      points.add(Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      ));
    }
    return points;
  }
}
