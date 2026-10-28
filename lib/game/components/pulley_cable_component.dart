/// Pulley cable component — renders top rotating pulley wheels at y = 12.0
/// and animated tension cables that dynamically stretch to the lifting bar's carriages.
/// Tints cables warning-orange when mechanical tilt limit (maxTiltDifferential = 9.0) is exceeded.
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/maze_theme_config.dart';
import 'lifting_bar_component.dart';

class PulleyCableComponent extends PositionComponent {
  final LiftingBarComponent liftingBar;
  final MazeThemeConfig theme;
  final double railLeftX;
  final double railRightX;
  final double pulleyY;

  double _wheelRotationLeft = 0.0;
  double _wheelRotationRight = 0.0;
  double _lastLeftY = 0.0;
  double _lastRightY = 0.0;

  PulleyCableComponent({
    required this.liftingBar,
    required this.theme,
    required this.railLeftX,
    required this.railRightX,
    this.pulleyY = 12.0,
  }) : super(priority: 15) {
    _lastLeftY = liftingBar.currentLeftY;
    _lastRightY = liftingBar.currentRightY;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Rotate pulley wheels based on carriage vertical motion
    final dLeftY = liftingBar.currentLeftY - _lastLeftY;
    final dRightY = liftingBar.currentRightY - _lastRightY;
    _lastLeftY = liftingBar.currentLeftY;
    _lastRightY = liftingBar.currentRightY;

    _wheelRotationLeft += dLeftY * 0.8;
    _wheelRotationRight += dRightY * 0.8;
  }

  @override
  void render(Canvas canvas) {
    final leftCarriageY = liftingBar.currentLeftY;
    final rightCarriageY = liftingBar.currentRightY;
    final isTensionWarning = liftingBar.isOverTilted;

    final cableColor = isTensionWarning
        ? theme.cableWarningColor
        : theme.cableNormalColor;

    // 1. Draw Left Pulley Wheel
    _renderPulleyMount(canvas, Offset(railLeftX, pulleyY), _wheelRotationLeft);
    // 2. Draw Right Pulley Wheel
    _renderPulleyMount(canvas, Offset(railRightX, pulleyY), _wheelRotationRight);

    // 3. Draw Dynamic Tension Cables
    _renderTensionCable(
      canvas,
      Offset(railLeftX, pulleyY + 0.8),
      Offset(railLeftX, leftCarriageY),
      cableColor,
      isTensionWarning,
    );

    _renderTensionCable(
      canvas,
      Offset(railRightX, pulleyY + 0.8),
      Offset(railRightX, rightCarriageY),
      cableColor,
      isTensionWarning,
    );
  }

  void _renderPulleyMount(Canvas canvas, Offset center, double rotation) {
    const radius = 1.35;

    // Shadow
    canvas.drawCircle(
      center.translate(0, 0.3),
      radius + 0.2,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4),
    );

    // Mount bracket
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: radius * 2.4, height: radius * 2.4),
        const Radius.circular(0.4),
      ),
      Paint()..color = theme.pulleyMountColor,
    );

    // Rotating pulley wheel
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final wheelGradient = RadialGradient(
      colors: [
        theme.pulleyWheelColor,
        theme.pulleyMountColor,
        Color.lerp(theme.pulleyMountColor, Colors.black, 0.7)!,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()..shader = wheelGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );

    // Wheel groove rim
    canvas.drawCircle(
      Offset.zero,
      radius * 0.85,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3,
    );

    // Wheel spokes
    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 0.25;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(-radius * 0.7, 0),
        Offset(radius * 0.7, 0),
        spokePaint,
      );
      canvas.rotate(3.14159 / 4);
    }

    // Center pin bolt
    canvas.drawCircle(Offset.zero, 0.35, Paint()..color = Colors.white);
    canvas.drawCircle(Offset.zero, 0.15, Paint()..color = Colors.black);

    canvas.restore();
  }

  void _renderTensionCable(
    Canvas canvas,
    Offset top,
    Offset bottom,
    Color color,
    bool isWarning,
  ) {
    if (bottom.dy <= top.dy) return;

    // Glowing aura if over-tilted tension warning
    if (isWarning) {
      canvas.drawLine(
        top,
        bottom,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..strokeWidth = 0.7
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
      );
    }

    // Main steel cable core
    canvas.drawLine(
      top,
      bottom,
      Paint()
        ..color = color.withValues(alpha: 0.95)
        ..strokeWidth = 0.28
        ..strokeCap = StrokeCap.round,
    );

    // Fine braided highlight
    canvas.drawLine(
      top,
      bottom,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 0.12,
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
