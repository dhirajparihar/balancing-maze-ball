/// Background component — renders atmospheric theme backdrop,
/// deep space nebulae, twinkling stars, and 2.5D depth layers.
library;

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/theme_data.dart';

class BackgroundComponent extends PositionComponent {
  final MazeThemeData theme;
  final double boardWidth;
  final double boardHeight;

  final List<_Star> _stars = [];
  double _time = 0;

  BackgroundComponent({
    required this.theme,
    required this.boardWidth,
    required this.boardHeight,
  }) : super(priority: -100) {
    // Generate deterministic twinkling stars
    final random = Random(42);
    for (int i = 0; i < 45; i++) {
      _stars.add(
        _Star(
          x: (random.nextDouble() * 1.6 - 0.3) * boardWidth,
          y: (random.nextDouble() * 1.6 - 0.3) * boardHeight,
          radius: 0.03 + random.nextDouble() * 0.06,
          blinkSpeed: 1.0 + random.nextDouble() * 2.5,
          phase: random.nextDouble() * pi * 2,
          brightness: 0.4 + random.nextDouble() * 0.6,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      -boardWidth * 0.4,
      -boardHeight * 0.3,
      boardWidth * 1.8,
      boardHeight * 1.6,
    );

    // 1. Deep backdrop base gradient
    final baseGradient = RadialGradient(
      center: const Alignment(0.0, -0.2),
      radius: 1.4,
      colors: [
        Color.lerp(theme.backgroundColor, theme.wallGlowColor, 0.12)!,
        theme.backgroundColor,
        Color.lerp(theme.backgroundColor, Colors.black, 0.6)!,
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    canvas.drawRect(
      rect,
      Paint()..shader = baseGradient.createShader(rect),
    );

    // 2. Cosmic nebula / atmospheric glow clouds
    final nebulaPaint1 = Paint()
      ..color = theme.wallGlowColor.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(boardWidth * 0.35, boardHeight * 0.45),
        width: boardWidth * 1.2,
        height: boardHeight * 0.8,
      ),
      nebulaPaint1,
    );

    final nebulaPaint2 = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(boardWidth * 0.7, boardHeight * 0.25),
        width: boardWidth * 0.9,
        height: boardHeight * 0.6,
      ),
      nebulaPaint2,
    );

    // 3. Cyberpunk circuit grid lines or subtle tech grid
    if (theme.id == 'cyberpunk_city' || theme.id == 'neon_aqua') {
      final gridPaint = Paint()
        ..color = theme.wallGlowColor.withValues(alpha: 0.035)
        ..strokeWidth = 0.02;

      for (double y = 0; y <= boardHeight; y += 1.0) {
        canvas.drawLine(
          Offset(-1.0, y),
          Offset(boardWidth + 1.0, y),
          gridPaint,
        );
      }
      for (double x = 0; x <= boardWidth; x += 1.0) {
        canvas.drawLine(
          Offset(x, -1.0),
          Offset(x, boardHeight + 1.0),
          gridPaint,
        );
      }
    }

    // 4. Twinkling stars
    for (final star in _stars) {
      final twinkle = 0.4 + 0.6 * sin(_time * star.blinkSpeed + star.phase).abs();
      final alpha = (star.brightness * twinkle).clamp(0.1, 1.0);

      // Star soft glow
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.radius * 2.2,
        Paint()
          ..color = theme.wallGlowColor.withValues(alpha: alpha * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.08),
      );

      // Star core
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.radius,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double blinkSpeed;
  final double phase;
  final double brightness;

  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.blinkSpeed,
    required this.phase,
    required this.brightness,
  });
}
