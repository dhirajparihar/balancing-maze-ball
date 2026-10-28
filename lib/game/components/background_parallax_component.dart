/// Background parallax component — renders the animated void behind cutout holes
/// (city skyline, rotating clockwork cogs, rainforest canopy, deep space nebula, candy clouds).
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/maze_theme_config.dart';

class BackgroundParallaxComponent extends PositionComponent {
  final double worldWidth;
  final double worldHeight;
  final MazeThemeConfig theme;

  double _time = 0.0;

  BackgroundParallaxComponent({
    required this.worldWidth,
    required this.worldHeight,
    required this.theme,
  }) : super(priority: -50);

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    ThemeProceduralRenderer.paintVoidBackground(
      canvas,
      Size(worldWidth, worldHeight),
      theme,
      time: _time,
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {}
}
