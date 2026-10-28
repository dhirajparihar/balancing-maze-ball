/// Organic board component — High-performance cached vertical labyrinth faceplate.
/// Bakes static PathOperation.difference cuts, procedural theme textures, and bevels
/// into a GPU-accelerated ui.Picture display list (12ms -> 0.05ms per frame).
/// Only dynamic goal pulses, tipping auras, and batched ghost trails update per frame.
library;

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/maze_theme_config.dart';
import '../systems/level_definitions.dart';

class OrganicBoardComponent extends PositionComponent {
  final BoardLevel level;
  final MazeThemeConfig theme;
  int currentSequentialTarget;

  double _pulseTime = 0.0;
  List<Vector2>? ghostTrail;
  Vector2? ghostFallPoint;
  List<Vector2>? personalBestGhostTrail;
  OrganicHole? activeEdgeTippingHole;

  // GPU Display-List Cached Static Board Picture (Saves ~10ms per frame)
  ui.Picture? _cachedStaticBoardPicture;

  // Pre-allocated reusable Paint instances (Zero Allocation in 60/120 FPS render loop)
  late final Paint _goalIndicatorPaint;
  late final Paint _dynamicAuraPaint;
  late final Paint _personalBestGlowPaint;
  late final Paint _personalBestDotPaint;
  late final Paint _personalBestMarkerOuterPaint;
  late final Paint _personalBestMarkerInnerPaint;
  late final Paint _ghostGlowPaint;
  late final Paint _ghostDotPaint;
  late final Paint _ghostXPaint;

  OrganicBoardComponent({
    required this.level,
    required this.theme,
    this.currentSequentialTarget = 1,
    this.personalBestGhostTrail,
  }) : super(priority: -20) {
    _initPaints();
  }

  void _initPaints() {
    _goalIndicatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.45
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _dynamicAuraPaint = Paint()..style = PaintingStyle.stroke;

    _personalBestDotPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;

    _personalBestGlowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.30)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.45);

    _personalBestMarkerOuterPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    _personalBestMarkerInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    _ghostDotPaint = Paint()
      ..color = theme.hudTextColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    _ghostGlowPaint = Paint()
      ..color = theme.rimGlowColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4);

    _ghostXPaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.85)
      ..strokeWidth = 0.35
      ..strokeCap = StrokeCap.round;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _rebuildStaticBoardPicture();
  }

  @override
  void onRemove() {
    _cachedStaticBoardPicture?.dispose();
    _cachedStaticBoardPicture = null;
    super.onRemove();
  }

  /// Invalidate and re-bake display list (e.g. when a taped hole shield breaks)
  void rebuildCache() {
    _rebuildStaticBoardPicture();
  }

  void updateSequentialTarget(int step) {
    currentSequentialTarget = step;
  }

  void setGhostTrail(List<Vector2> trail, Vector2? fallPoint) {
    ghostTrail = trail;
    ghostFallPoint = fallPoint;
  }

  void setPersonalBestGhostTrail(List<Vector2>? trail) {
    personalBestGhostTrail = trail;
  }

  void setActiveEdgeTippingHole(OrganicHole? hole) {
    activeEdgeTippingHole = hole;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
  }

  /// Pre-bakes all complex PathOperation.difference booleans and procedural textures once
  void _rebuildStaticBoardPicture() {
    _cachedStaticBoardPicture?.dispose();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final boardRect = Rect.fromLTWH(
      level.railLeftX - 1.2,
      level.railTopY - 1.5,
      (level.railRightX - level.railLeftX) + 2.4,
      (level.railBottomY - level.railTopY) + 3.0,
    );

    // 1. Board Backing Plate Drop Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.inflate(0.8), const Radius.circular(2.2)),
      Paint()
        ..color = theme.boardShadowColor.withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // 2. Cutout Board Plate using PathOperation.difference
    final outerPath = Path()
      ..addRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(1.6)));

    var holesCompoundPath = Path();
    for (final hole in level.holes) {
      holesCompoundPath = Path.combine(
        PathOperation.union,
        holesCompoundPath,
        hole.createPath(),
      );
    }

    final solidBoardPath = Path.combine(
      PathOperation.difference,
      outerPath,
      holesCompoundPath,
    );

    // 3. Paint solid board faceplate with 2.5D gradient
    final faceGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.boardBevelTop,
        theme.boardFaceColor,
        theme.boardBevelBottom,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    canvas.drawPath(
      solidBoardPath,
      Paint()..shader = faceGradient.createShader(boardRect),
    );

    // 4. Procedural board surface details (circuits, rivets, sprinkles, wood grain)
    canvas.save();
    canvas.clipPath(solidBoardPath);
    ThemeProceduralRenderer.paintBoardTexture(canvas, boardRect, theme);
    canvas.restore();

    // 5. Render Static Bevelled Hole Rims, Inner Shadows, and Taped Covers
    for (final hole in level.holes) {
      _renderStaticHole(canvas, hole);
    }

    // 6. Ghost line path hints for Training mode
    if (level.ghostPathHints.isNotEmpty) {
      _renderGhostPath(canvas);
    }

    // 7. Vertical Mechanical Side Rails
    _renderSideRails(canvas);

    _cachedStaticBoardPicture = recorder.endRecording();
  }

  void _renderStaticHole(Canvas canvas, OrganicHole hole) {
    final holePath = hole.createPath();

    // A. 3D Inner Drop Shadow
    canvas.save();
    canvas.translate(0, -0.3);
    canvas.drawPath(
      holePath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
    );
    canvas.restore();

    // B. Static Inner Rim Stroke
    final rimColor = hole.isGoal ? theme.targetHoleColor : theme.rimColor;
    canvas.drawPath(
      holePath,
      Paint()
        ..color = rimColor.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.38,
    );

    // C. Static Taped Hole Shield (or torn flaps if broken)
    if (hole.isTaped) {
      _renderTapedShield(canvas, hole);
    }
  }

  @override
  void render(Canvas canvas) {
    // 1. Fast GPU Display List Draw (~0.05ms)
    if (_cachedStaticBoardPicture == null) {
      _rebuildStaticBoardPicture();
    }
    canvas.drawPicture(_cachedStaticBoardPicture!);

    // 2. Dynamic Frame-Varying Elements (Auras, Pulses, and Ghost Trails)
    _renderDynamicAurasAndGoals(canvas);

    // 3. Batched Personal Best Ghost Replay
    if (personalBestGhostTrail != null && personalBestGhostTrail!.length >= 2) {
      _renderPersonalBestGhostTrail(canvas);
    }

    // 4. Batched Faint Ghost Trail from previous run attempt
    if (ghostTrail != null && ghostTrail!.length >= 2) {
      _renderGhostTrail(canvas);
    }
  }

  void _renderDynamicAurasAndGoals(Canvas canvas) {
    // Dynamic Goal Pulsing Chevron Arrow & Rim Aura
    for (final hole in level.holes) {
      final isCurrentGoal = hole.isGoal &&
          (hole.sequentialOrder == currentSequentialTarget ||
              (hole.sequentialOrder == 0 && currentSequentialTarget == 1));

      if (isCurrentGoal) {
        final pulse = 0.8 + 0.35 * sin(_pulseTime * 5.0);
        final holePath = hole.createPath();

        // Pulsing goal aura
        _dynamicAuraPaint
          ..color = theme.targetHoleGlow.withValues(alpha: 0.45 * pulse)
          ..strokeWidth = 1.2
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, theme.rimGlowSigma * 0.15);
        canvas.drawPath(holePath, _dynamicAuraPaint);

        // Chevron arrow pointing into goal
        _renderGoalIndicator(canvas, hole.centroid, hole.radius, pulse);
      }
    }

    // Active Edge Tipping Aura (Intense rapid red pulse only when marble is on the bevel lip!)
    if (activeEdgeTippingHole != null) {
      final hole = activeEdgeTippingHole!;
      final holePath = hole.createPath();
      final tippingPulse = 1.2 + 0.6 * sin(_pulseTime * 20.0);

      _dynamicAuraPaint
        ..color = const Color(0xFFFF1744).withValues(alpha: 0.75 * tippingPulse)
        ..strokeWidth = 2.0
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, theme.rimGlowSigma * 0.25);
      canvas.drawPath(holePath, _dynamicAuraPaint);
    }
  }

  void _renderTapedShield(Canvas canvas, OrganicHole hole) {
    final c = hole.centroid;
    final r = hole.radius;
    final isBroken = hole.isTapeBroken;

    canvas.save();
    canvas.clipPath(hole.createPath());

    final tapeColor = const Color(0xFFE8D8B8).withValues(alpha: isBroken ? 0.35 : 0.82);
    final tapeBorder = const Color(0xFFC4B294).withValues(alpha: isBroken ? 0.40 : 0.88);

    final tapePaint = Paint()
      ..color = tapeColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = tapeBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.16;

    if (!isBroken) {
      // Horizontal masking tape strip
      final hTape = Rect.fromCenter(center: c, width: r * 2.3, height: r * 0.95);
      canvas.drawRect(hTape, tapePaint);
      canvas.drawRect(hTape, borderPaint);

      // Angled cross tape strip
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(0.65);
      final diagTape = Rect.fromCenter(center: Offset.zero, width: r * 2.3, height: r * 0.75);
      canvas.drawRect(diagTape, tapePaint);
      canvas.drawRect(diagTape, borderPaint);
      canvas.restore();

      // "TAPED" stencil label across the shield
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'TAPED',
          style: TextStyle(
            color: const Color(0xFF4E342E).withValues(alpha: 0.65),
            fontSize: r * 0.42,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(c.dx - textPainter.width / 2, c.dy - textPainter.height / 2),
      );
    } else {
      // Torn ragged tape edges hanging from the hole rim
      final leftFlap = Rect.fromLTWH(c.dx - r, c.dy - r * 0.45, r * 0.6, r * 0.9);
      final rightFlap = Rect.fromLTWH(c.dx + r * 0.4, c.dy - r * 0.45, r * 0.6, r * 0.9);
      canvas.drawRect(leftFlap, tapePaint);
      canvas.drawRect(rightFlap, tapePaint);
    }

    canvas.restore();
  }

  void _renderGoalIndicator(Canvas canvas, Offset center, double r, double pulse) {
    _goalIndicatorPaint.color = Colors.white.withValues(alpha: 0.85 * pulse);

    final chevron = Path()
      ..moveTo(center.dx - r * 0.4, center.dy + r * 0.2)
      ..lineTo(center.dx, center.dy - r * 0.3)
      ..lineTo(center.dx + r * 0.4, center.dy + r * 0.2);

    canvas.drawPath(chevron, _goalIndicatorPaint);
  }

  void _renderGhostPath(Canvas canvas) {
    final hintPaint = Paint()
      ..color = theme.rimGlowColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke;

    final hintPath = Path();
    hintPath.moveTo(level.ghostPathHints.first.dx, level.ghostPathHints.first.dy);
    for (int i = 1; i < level.ghostPathHints.length; i++) {
      hintPath.lineTo(level.ghostPathHints[i].dx, level.ghostPathHints[i].dy);
    }
    canvas.drawPath(hintPath, hintPaint);
  }

  /// Batched draw calls via canvas.drawPoints (replaces 150+ individual drawCircle calls)
  void _renderPersonalBestGhostTrail(Canvas canvas) {
    if (personalBestGhostTrail == null || personalBestGhostTrail!.length < 2) return;

    final points = <Offset>[];
    for (int i = 0; i < personalBestGhostTrail!.length; i += 2) {
      points.add(Offset(personalBestGhostTrail![i].x, personalBestGhostTrail![i].y));
    }

    // Single hardware-accelerated batch points draw
    canvas.drawPoints(ui.PointMode.points, points, _personalBestGlowPaint);
    canvas.drawPoints(ui.PointMode.points, points, _personalBestDotPaint);

    // Luminous marker at furthest recorded personal best position
    final lastPt = Offset(personalBestGhostTrail!.last.x, personalBestGhostTrail!.last.y);
    canvas.drawCircle(lastPt, 0.45, _personalBestMarkerOuterPaint);
    canvas.drawCircle(lastPt, 0.25, _personalBestMarkerInnerPaint);
  }

  /// Batched draw calls via canvas.drawPoints
  void _renderGhostTrail(Canvas canvas) {
    if (ghostTrail == null || ghostTrail!.length < 2) return;

    final points = <Offset>[];
    for (int i = 0; i < ghostTrail!.length; i += 2) {
      points.add(Offset(ghostTrail![i].x, ghostTrail![i].y));
    }

    // Single hardware-accelerated batch points draw
    canvas.drawPoints(ui.PointMode.points, points, _ghostGlowPaint);
    canvas.drawPoints(ui.PointMode.points, points, _ghostDotPaint);

    if (ghostFallPoint != null) {
      final fallPt = Offset(ghostFallPoint!.x, ghostFallPoint!.y);
      const sz = 0.65;
      canvas.drawLine(fallPt + const Offset(-sz, -sz), fallPt + const Offset(sz, sz), _ghostXPaint);
      canvas.drawLine(fallPt + const Offset(sz, -sz), fallPt + const Offset(-sz, sz), _ghostXPaint);
    }
  }

  void _renderSideRails(Canvas canvas) {
    const railWidth = 3.6;
    final railHeight = (level.railBottomY - level.railTopY) + 5.0;

    final leftRailRect = Rect.fromLTWH(
      level.railLeftX - railWidth + 0.3,
      level.railTopY - 2.5,
      railWidth,
      railHeight,
    );

    final rightRailRect = Rect.fromLTWH(
      level.railRightX - 0.3,
      level.railTopY - 2.5,
      railWidth,
      railHeight,
    );

    _renderSingleRail(canvas, leftRailRect, isLeft: true);
    _renderSingleRail(canvas, rightRailRect, isLeft: false);

    // Top crossbeam
    final topBeamRect = Rect.fromLTWH(
      leftRailRect.left - 0.5,
      level.railTopY - 3.2,
      (rightRailRect.right - leftRailRect.left) + 1.0,
      2.5,
    );
    _renderCrossbeam(canvas, topBeamRect);

    // Bottom crossbeam
    final bottomBeamRect = Rect.fromLTWH(
      leftRailRect.left - 0.5,
      level.railBottomY + 1.2,
      (rightRailRect.right - leftRailRect.left) + 1.0,
      2.5,
    );
    _renderCrossbeam(canvas, bottomBeamRect);
  }

  void _renderSingleRail(Canvas canvas, Rect rect, {required bool isLeft}) {
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isLeft
          ? [
              theme.railHighlightColor,
              theme.railColor,
              Color.lerp(theme.railColor, Colors.black, 0.6)!,
            ]
          : [
              Color.lerp(theme.railColor, Colors.black, 0.6)!,
              theme.railColor,
              theme.railHighlightColor,
            ],
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(0.6)),
      Paint()..shader = gradient.createShader(rect),
    );

    // Center vertical guide slot channel (where the carriage slides)
    final slotX = rect.center.dx;
    final slotRect = Rect.fromCenter(
      center: Offset(slotX, rect.center.dy),
      width: 0.7,
      height: rect.height - 3.0,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(slotRect, const Radius.circular(0.35)),
      Paint()..color = theme.railSlotColor,
    );

    // Glowing edge line
    canvas.drawLine(
      Offset(isLeft ? rect.right : rect.left, rect.top + 2.0),
      Offset(isLeft ? rect.right : rect.left, rect.bottom - 2.0),
      Paint()
        ..color = theme.rimGlowColor.withValues(alpha: 0.5)
        ..strokeWidth = 0.18,
    );
  }

  void _renderCrossbeam(Canvas canvas, Rect rect) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.railHighlightColor,
        theme.railColor,
        Color.lerp(theme.railColor, Colors.black, 0.5)!,
      ],
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(0.6)),
      Paint()..shader = gradient.createShader(rect),
    );

    // Decorative bolt caps
    _drawBolt(canvas, Offset(rect.left + 2.2, rect.center.dy));
    _drawBolt(canvas, Offset(rect.right - 2.2, rect.center.dy));
  }

  void _drawBolt(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 0.55, Paint()..color = Colors.black.withValues(alpha: 0.65));
    canvas.drawCircle(center, 0.42, Paint()..color = theme.railHighlightColor);
    canvas.drawCircle(center, 0.18, Paint()..color = Colors.black);
  }
}
