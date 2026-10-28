/// Hot-swappable multi-theme skinning engine for Balancing Maze.
/// Zero external image asset dependencies — all procedural Canvas rendering.
library;

import 'dart:math';
import 'package:flutter/material.dart';

enum ThemeType {
  classicCyan,
  cyberpunkNeon,
  steampunkBrass,
  jungleBamboo,
  candyFrosting,
  deepSpace,
}

class MazeThemeConfig {
  final ThemeType type;
  final String id;
  final String name;
  final String subtitle;
  final int unlockCost;
  final bool isDefault;

  // Board colors
  final Color boardFaceColor;
  final Color boardBevelTop;
  final Color boardBevelBottom;
  final Color boardShadowColor;

  // Hole rim colors
  final Color rimColor;
  final Color rimGlowColor;
  final double rimGlowSigma;
  final Color targetHoleColor;
  final Color targetHoleGlow;

  // Rail & Pulley colors
  final Color railColor;
  final Color railSlotColor;
  final Color railHighlightColor;
  final Color pulleyMountColor;
  final Color pulleyWheelColor;
  final Color cableNormalColor;
  final Color cableWarningColor;

  // Lifting bar colors
  final Color barBodyColor;
  final Color barHighlightColor;
  final Color barShadowColor;
  final Color carriageBlockColor;

  // Marble appearance
  final Color marbleBaseColor;
  final Color marbleHighlightColor;
  final Color marbleSpecularColor;
  final Color marbleShadowColor;
  final bool marbleGlows;

  // Slider controls appearance
  final Color sliderContainerBg;
  final Color sliderContainerBorder;
  final Color sliderStemColor;
  final Color sliderActiveStemColor;
  final Color sliderThumbInner;
  final Color sliderThumbOuter;
  final Color sliderThumbGlow;
  final Color sliderLabelColor;

  // HUD & UI styling
  final Color hudBgColor;
  final Color hudBorderColor;
  final Color hudTextColor;
  final Color hudAccentColor;
  final Color hudTimerWarningColor;

  // Background void styling
  final Color voidBgColor;
  final Color voidSecondaryColor;

  const MazeThemeConfig({
    required this.type,
    required this.id,
    required this.name,
    required this.subtitle,
    this.unlockCost = 0,
    this.isDefault = false,
    required this.boardFaceColor,
    required this.boardBevelTop,
    required this.boardBevelBottom,
    required this.boardShadowColor,
    required this.rimColor,
    required this.rimGlowColor,
    this.rimGlowSigma = 4.0,
    required this.targetHoleColor,
    required this.targetHoleGlow,
    required this.railColor,
    required this.railSlotColor,
    required this.railHighlightColor,
    required this.pulleyMountColor,
    required this.pulleyWheelColor,
    required this.cableNormalColor,
    this.cableWarningColor = const Color(0xFFFF5252),
    required this.barBodyColor,
    required this.barHighlightColor,
    required this.barShadowColor,
    required this.carriageBlockColor,
    required this.marbleBaseColor,
    required this.marbleHighlightColor,
    required this.marbleSpecularColor,
    required this.marbleShadowColor,
    this.marbleGlows = false,
    required this.sliderContainerBg,
    required this.sliderContainerBorder,
    required this.sliderStemColor,
    required this.sliderActiveStemColor,
    required this.sliderThumbInner,
    required this.sliderThumbOuter,
    required this.sliderThumbGlow,
    required this.sliderLabelColor,
    required this.hudBgColor,
    required this.hudBorderColor,
    required this.hudTextColor,
    required this.hudAccentColor,
    this.hudTimerWarningColor = const Color(0xFFFF3D00),
    required this.voidBgColor,
    required this.voidSecondaryColor,
  });

  /// 1. Classic Cyan — 3D-Printed Matte Teal from Reference Images 1 & 2
  static const classicCyan = MazeThemeConfig(
    type: ThemeType.classicCyan,
    id: 'classic_cyan',
    name: 'CLASSIC CYAN',
    subtitle: '3D-Printed Matte',
    isDefault: true,
    unlockCost: 0,
    boardFaceColor: Color(0xFF28B5D1),
    boardBevelTop: Color(0xFF5CE1F6),
    boardBevelBottom: Color(0xFF147589),
    boardShadowColor: Color(0xFF041920),
    rimColor: Color(0xFF8CF0DF),
    rimGlowColor: Color(0xFF4EE8CF),
    rimGlowSigma: 4.5,
    targetHoleColor: Color(0xFF00E676),
    targetHoleGlow: Color(0xFF69F0AE),
    railColor: Color(0xFF239BB3),
    railSlotColor: Color(0xFF0C4652),
    railHighlightColor: Color(0xFF7CE4F7),
    pulleyMountColor: Color(0xFF1B7D91),
    pulleyWheelColor: Color(0xFFDDF7FD),
    cableNormalColor: Color(0xFFC7E8F1),
    cableWarningColor: Color(0xFFFF7043),
    barBodyColor: Color(0xFF4AD2EC),
    barHighlightColor: Color(0xFFB1F3FE),
    barShadowColor: Color(0xFF156677),
    carriageBlockColor: Color(0xFF1F8CA2),
    marbleBaseColor: Color(0xFFF0F4F8),
    marbleHighlightColor: Color(0xFFFFFFFF),
    marbleSpecularColor: Color(0xFFFFFFFF),
    marbleShadowColor: Color(0x7704151B),
    marbleGlows: false,
    sliderContainerBg: Color(0x330A2A33),
    sliderContainerBorder: Color(0x8828B5D1),
    sliderStemColor: Color(0x550C4652),
    sliderActiveStemColor: Color(0xFFFFB74D),
    sliderThumbInner: Color(0xFFFFFFFF),
    sliderThumbOuter: Color(0xFFFFB74D),
    sliderThumbGlow: Color(0xCCFF9800),
    sliderLabelColor: Color(0xFFFFB74D),
    hudBgColor: Color(0xB0081C26),
    hudBorderColor: Color(0x7728B5D1),
    hudTextColor: Color(0xFF7DE9FC),
    hudAccentColor: Color(0xFFFFB74D),
    voidBgColor: Color(0xFF040A10),
    voidSecondaryColor: Color(0xFF0B1E2B),
  );

  /// 2. Cyberpunk Neon — Neon Circuit PCB from Reference Image 3
  static const cyberpunkNeon = MazeThemeConfig(
    type: ThemeType.cyberpunkNeon,
    id: 'cyberpunk_neon',
    name: 'CYBERPUNK NEON',
    subtitle: 'PCB Circuit Grid',
    unlockCost: 2500,
    boardFaceColor: Color(0xFF15102A),
    boardBevelTop: Color(0xFF38236E),
    boardBevelBottom: Color(0xFF0B0618),
    boardShadowColor: Color(0xFF03010A),
    rimColor: Color(0xFF00E5FF),
    rimGlowColor: Color(0xFFE040FB),
    rimGlowSigma: 6.0,
    targetHoleColor: Color(0xFF00FF66),
    targetHoleGlow: Color(0xFF00E5FF),
    railColor: Color(0xFF1E143E),
    railSlotColor: Color(0xFF0A0518),
    railHighlightColor: Color(0xFF00E5FF),
    pulleyMountColor: Color(0xFF2C1C5A),
    pulleyWheelColor: Color(0xFFE040FB),
    cableNormalColor: Color(0xFF00E5FF),
    cableWarningColor: Color(0xFFFF1744),
    barBodyColor: Color(0xFF2A1C54),
    barHighlightColor: Color(0xFF00E5FF),
    barShadowColor: Color(0xFF090414),
    carriageBlockColor: Color(0xFF3C207D),
    marbleBaseColor: Color(0xFFB388FF),
    marbleHighlightColor: Color(0xFF00E5FF),
    marbleSpecularColor: Color(0xFFFFFFFF),
    marbleShadowColor: Color(0x99000000),
    marbleGlows: true,
    sliderContainerBg: Color(0x4415102A),
    sliderContainerBorder: Color(0xAA00E5FF),
    sliderStemColor: Color(0x552C1C5A),
    sliderActiveStemColor: Color(0xFF00E5FF),
    sliderThumbInner: Color(0xFFFFFFFF),
    sliderThumbOuter: Color(0xFF00E5FF),
    sliderThumbGlow: Color(0xCCE040FB),
    sliderLabelColor: Color(0xFF00E5FF),
    hudBgColor: Color(0xC0100B22),
    hudBorderColor: Color(0x9900E5FF),
    hudTextColor: Color(0xFF00E5FF),
    hudAccentColor: Color(0xFFE040FB),
    voidBgColor: Color(0xFF06030E),
    voidSecondaryColor: Color(0xFF1D0E38),
  );

  /// 3. Steampunk Brass — Clockwork Machinery from Reference Image 4
  static const steampunkBrass = MazeThemeConfig(
    type: ThemeType.steampunkBrass,
    id: 'steampunk_brass',
    name: 'STEAMPUNK BRASS',
    subtitle: 'Clockwork Gears',
    unlockCost: 3500,
    boardFaceColor: Color(0xFF8D6E42),
    boardBevelTop: Color(0xFFD4AF37),
    boardBevelBottom: Color(0xFF4A3416),
    boardShadowColor: Color(0xFF1C1306),
    rimColor: Color(0xFFD4AF37),
    rimGlowColor: Color(0xFFFFD54F),
    rimGlowSigma: 3.5,
    targetHoleColor: Color(0xFF00E676),
    targetHoleGlow: Color(0xFFFFD54F),
    railColor: Color(0xFF6D4C24),
    railSlotColor: Color(0xFF2D1B08),
    railHighlightColor: Color(0xFFF3C65D),
    pulleyMountColor: Color(0xFF4E3618),
    pulleyWheelColor: Color(0xFFD4AF37),
    cableNormalColor: Color(0xFFC49A45),
    cableWarningColor: Color(0xFFFF3D00),
    barBodyColor: Color(0xFFB08D57),
    barHighlightColor: Color(0xFFFFF0B3),
    barShadowColor: Color(0xFF3E280C),
    carriageBlockColor: Color(0xFF6B4E26),
    marbleBaseColor: Color(0xFFC87D55),
    marbleHighlightColor: Color(0xFFFFC0A0),
    marbleSpecularColor: Color(0xFFFFFFFF),
    marbleShadowColor: Color(0x99180C03),
    marbleGlows: false,
    sliderContainerBg: Color(0x444A3416),
    sliderContainerBorder: Color(0xAAD4AF37),
    sliderStemColor: Color(0x662D1B08),
    sliderActiveStemColor: Color(0xFFD4AF37),
    sliderThumbInner: Color(0xFFFFFFFF),
    sliderThumbOuter: Color(0xFFD4AF37),
    sliderThumbGlow: Color(0xCCFFA000),
    sliderLabelColor: Color(0xFFD4AF37),
    hudBgColor: Color(0xD029190A),
    hudBorderColor: Color(0x99D4AF37),
    hudTextColor: Color(0xFFFCE4A6),
    hudAccentColor: Color(0xFFFFAB40),
    voidBgColor: Color(0xFF150C03),
    voidSecondaryColor: Color(0xFF331E09),
  );

  /// 4. Jungle Bamboo — Ancient Rainforest from Reference Image 4
  static const jungleBamboo = MazeThemeConfig(
    type: ThemeType.jungleBamboo,
    id: 'jungle_bamboo',
    name: 'JUNGLE BAMBOO',
    subtitle: 'Rainforest Canopy',
    unlockCost: 4000,
    boardFaceColor: Color(0xFF3E5C32),
    boardBevelTop: Color(0xFF7CB342),
    boardBevelBottom: Color(0xFF1E3316),
    boardShadowColor: Color(0xFF0C1708),
    rimColor: Color(0xFFC5E1A5),
    rimGlowColor: Color(0xFF81C784),
    rimGlowSigma: 3.5,
    targetHoleColor: Color(0xFF00E676),
    targetHoleGlow: Color(0xFF69F0AE),
    railColor: Color(0xFF558B2F),
    railSlotColor: Color(0xFF1C310E),
    railHighlightColor: Color(0xFFAED581),
    pulleyMountColor: Color(0xFF33691E),
    pulleyWheelColor: Color(0xFFDCEDC8),
    cableNormalColor: Color(0xFFD7CCC8),
    cableWarningColor: Color(0xFFFF5722),
    barBodyColor: Color(0xFF689F38),
    barHighlightColor: Color(0xFFC5E1A5),
    barShadowColor: Color(0xFF274213),
    carriageBlockColor: Color(0xFF456B23),
    marbleBaseColor: Color(0xFF8D6E63),
    marbleHighlightColor: Color(0xFFD7CCC8),
    marbleSpecularColor: Color(0xFFFFFFFF),
    marbleShadowColor: Color(0x88091406),
    marbleGlows: false,
    sliderContainerBg: Color(0x441E3316),
    sliderContainerBorder: Color(0xAA7CB342),
    sliderStemColor: Color(0x661C310E),
    sliderActiveStemColor: Color(0xFFC5E1A5),
    sliderThumbInner: Color(0xFFFFFFFF),
    sliderThumbOuter: Color(0xFF7CB342),
    sliderThumbGlow: Color(0xCC689F38),
    sliderLabelColor: Color(0xFFC5E1A5),
    hudBgColor: Color(0xD012220D),
    hudBorderColor: Color(0x887CB342),
    hudTextColor: Color(0xFFDCEDC8),
    hudAccentColor: Color(0xFFFFD54F),
    voidBgColor: Color(0xFF071205),
    voidSecondaryColor: Color(0xFF172B10),
  );

  /// 5. Candy Frosting — Sweet Glaze from Reference Image 4
  static const candyFrosting = MazeThemeConfig(
    type: ThemeType.candyFrosting,
    id: 'candy_frosting',
    name: 'CANDY FROSTING',
    subtitle: 'Sweet Sprinkles',
    unlockCost: 4500,
    boardFaceColor: Color(0xFF72C7DF),
    boardBevelTop: Color(0xFFFF80AB),
    boardBevelBottom: Color(0xFF3B8DA0),
    boardShadowColor: Color(0xFF183D45),
    rimColor: Color(0xFFFF80AB),
    rimGlowColor: Color(0xFFFF4081),
    rimGlowSigma: 4.5,
    targetHoleColor: Color(0xFFFF4081),
    targetHoleGlow: Color(0xFFFF80AB),
    railColor: Color(0xFFFF80AB),
    railSlotColor: Color(0xFF881C44),
    railHighlightColor: Color(0xFFFFD1DF),
    pulleyMountColor: Color(0xFFE91E63),
    pulleyWheelColor: Color(0xFFFFFFFF),
    cableNormalColor: Color(0xFFFFFFFF),
    cableWarningColor: Color(0xFFFF1744),
    barBodyColor: Color(0xFFFFFFFF),
    barHighlightColor: Color(0xFFFF80AB),
    barShadowColor: Color(0xFFD81B60),
    carriageBlockColor: Color(0xFFFF4081),
    marbleBaseColor: Color(0xFFFFFFFF),
    marbleHighlightColor: Color(0xFFFFD1DF),
    marbleSpecularColor: Color(0xFFFFFFFF),
    marbleShadowColor: Color(0x66000000),
    marbleGlows: false,
    sliderContainerBg: Color(0x44FF80AB),
    sliderContainerBorder: Color(0xCCFF4081),
    sliderStemColor: Color(0x44881C44),
    sliderActiveStemColor: Color(0xFFFF4081),
    sliderThumbInner: Color(0xFFFFFFFF),
    sliderThumbOuter: Color(0xFFFF4081),
    sliderThumbGlow: Color(0xCCFF80AB),
    sliderLabelColor: Color(0xFFFF80AB),
    hudBgColor: Color(0xD02B1320),
    hudBorderColor: Color(0x99FF80AB),
    hudTextColor: Color(0xFFFFD1DF),
    hudAccentColor: Color(0xFFFFD700),
    voidBgColor: Color(0xFF1C0D17),
    voidSecondaryColor: Color(0xFF3D162C),
  );

  /// 6. Deep Space — Volcanic Nebula from Reference Image 3 & 5
  static const deepSpace = MazeThemeConfig(
    type: ThemeType.deepSpace,
    id: 'deep_space',
    name: 'DEEP SPACE',
    subtitle: 'Cosmic Nebula',
    unlockCost: 5000,
    boardFaceColor: Color(0xFF261D3A),
    boardBevelTop: Color(0xFFE040FB),
    boardBevelBottom: Color(0xFF0F0B18),
    boardShadowColor: Color(0xFF05030A),
    rimColor: Color(0xFFFFAB40),
    rimGlowColor: Color(0xFFFF6D00),
    rimGlowSigma: 5.5,
    targetHoleColor: Color(0xFF7C4DFF),
    targetHoleGlow: Color(0xFF00E5FF),
    railColor: Color(0xFF38255B),
    railSlotColor: Color(0xFF120B20),
    railHighlightColor: Color(0xFFE040FB),
    pulleyMountColor: Color(0xFF4C2A80),
    pulleyWheelColor: Color(0xFFFFD54F),
    cableNormalColor: Color(0xFF00E5FF),
    cableWarningColor: Color(0xFFFF1744),
    barBodyColor: Color(0xFF3A2361),
    barHighlightColor: Color(0xFFE040FB),
    barShadowColor: Color(0xFF130925),
    carriageBlockColor: Color(0xFF673AB7),
    marbleBaseColor: Color(0xFFFFAB40),
    marbleHighlightColor: Color(0xFFFFF3E0),
    marbleSpecularColor: Color(0xFFFFFFFF),
    marbleShadowColor: Color(0x99000000),
    marbleGlows: true,
    sliderContainerBg: Color(0x44261D3A),
    sliderContainerBorder: Color(0xAAE040FB),
    sliderStemColor: Color(0x55120B20),
    sliderActiveStemColor: Color(0xFFFFAB40),
    sliderThumbInner: Color(0xFFFFFFFF),
    sliderThumbOuter: Color(0xFFFFAB40),
    sliderThumbGlow: Color(0xCCFF6D00),
    sliderLabelColor: Color(0xFFFFAB40),
    hudBgColor: Color(0xD0110A1E),
    hudBorderColor: Color(0x99E040FB),
    hudTextColor: Color(0xFFE1BEE7),
    hudAccentColor: Color(0xFFFFAB40),
    voidBgColor: Color(0xFF05020D),
    voidSecondaryColor: Color(0xFF1A0A33),
  );

  static const List<MazeThemeConfig> allThemes = [
    classicCyan,
    cyberpunkNeon,
    steampunkBrass,
    jungleBamboo,
    candyFrosting,
    deepSpace,
  ];

  static MazeThemeConfig getById(String id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => classicCyan,
    );
  }

  static MazeThemeConfig getByType(ThemeType type) {
    return allThemes.firstWhere(
      (t) => t.type == type,
      orElse: () => classicCyan,
    );
  }
}

/// Procedural Canvas Skinners for Themes (Runs at 60 FPS without external image files)
class ThemeProceduralRenderer {
  ThemeProceduralRenderer._();

  /// Paint procedural board surface patterns (PCB circuits, sprinkles, wood grain, rivets)
  static void paintBoardTexture(Canvas canvas, Rect boardRect, MazeThemeConfig theme) {
    switch (theme.type) {
      case ThemeType.cyberpunkNeon:
        _paintPcbCircuits(canvas, boardRect, theme);
        break;
      case ThemeType.steampunkBrass:
        _paintBrassRivetsAndGears(canvas, boardRect, theme);
        break;
      case ThemeType.jungleBamboo:
        _paintWoodGrainAndVines(canvas, boardRect, theme);
        break;
      case ThemeType.candyFrosting:
        _paintCandySprinkles(canvas, boardRect, theme);
        break;
      case ThemeType.deepSpace:
        _paintNebulaVeins(canvas, boardRect, theme);
        break;
      case ThemeType.classicCyan:
        _paintMatte3dPrintTexture(canvas, boardRect, theme);
        break;
    }
  }

  /// Paint procedural background void patterns seen through cutouts
  static void paintVoidBackground(
    Canvas canvas,
    Size size,
    MazeThemeConfig theme, {
    double time = 0.0,
  }) {
    // 1. Base gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 1.2,
        colors: [
          theme.voidSecondaryColor,
          theme.voidBgColor,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Dynamic animated background elements
    switch (theme.type) {
      case ThemeType.cyberpunkNeon:
        _paintCitySkylineBackground(canvas, size, time);
        break;
      case ThemeType.steampunkBrass:
        _paintRotatingClockworkBackground(canvas, size, time);
        break;
      case ThemeType.jungleBamboo:
        _paintRainforestCanopyBackground(canvas, size, time);
        break;
      case ThemeType.candyFrosting:
        _paintCandyCloudsBackground(canvas, size, time);
        break;
      case ThemeType.deepSpace:
        _paintGalaxyNebulaBackground(canvas, size, time);
        break;
      case ThemeType.classicCyan:
        _paintDustParticlesBackground(canvas, size, time);
        break;
    }
  }

  // --- Board Surface Shaders ---

  static void _paintPcbCircuits(Canvas canvas, Rect rect, MazeThemeConfig theme) {
    final tracePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.28)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFE040FB).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Fixed procedural circuit routes across the board
    final paths = [
      Path()
        ..moveTo(rect.left + 20, rect.top + 60)
        ..lineTo(rect.left + 50, rect.top + 90)
        ..lineTo(rect.left + 50, rect.top + 220)
        ..lineTo(rect.left + 90, rect.top + 260),
      Path()
        ..moveTo(rect.right - 20, rect.top + 80)
        ..lineTo(rect.right - 60, rect.top + 120)
        ..lineTo(rect.right - 60, rect.top + 340)
        ..lineTo(rect.right - 100, rect.top + 380),
      Path()
        ..moveTo(rect.left + 30, rect.bottom - 120)
        ..lineTo(rect.left + 70, rect.bottom - 80)
        ..lineTo(rect.left + 140, rect.bottom - 80),
      Path()
        ..moveTo(rect.right - 40, rect.bottom - 160)
        ..lineTo(rect.right - 80, rect.bottom - 120)
        ..lineTo(rect.right - 80, rect.bottom - 60),
    ];

    for (final p in paths) {
      canvas.drawPath(p, tracePaint);
    }

    // Micro-LED indicator dots
    final dots = [
      Offset(rect.left + 90, rect.top + 260),
      Offset(rect.right - 100, rect.top + 380),
      Offset(rect.left + 140, rect.bottom - 80),
      Offset(rect.right - 80, rect.bottom - 60),
      Offset(rect.left + 20, rect.top + 60),
      Offset(rect.right - 20, rect.top + 80),
    ];

    for (final d in dots) {
      canvas.drawCircle(d, 2.5, dotPaint);
    }
  }

  static void _paintBrassRivetsAndGears(Canvas canvas, Rect rect, MazeThemeConfig theme) {
    final rivetPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Rivets along the board perimeter
    for (double y = rect.top + 20; y < rect.bottom - 20; y += 45) {
      final leftPoint = Offset(rect.left + 10, y);
      final rightPoint = Offset(rect.right - 10, y);
      canvas.drawCircle(leftPoint, 3.0, rivetPaint);
      canvas.drawCircle(leftPoint.translate(0, 1), 3.0, shadowPaint);
      canvas.drawCircle(rightPoint, 3.0, rivetPaint);
      canvas.drawCircle(rightPoint.translate(0, 1), 3.0, shadowPaint);
    }
  }

  static void _paintWoodGrainAndVines(Canvas canvas, Rect rect, MazeThemeConfig theme) {
    final vinePaint = Paint()
      ..color = const Color(0xFF689F38).withValues(alpha: 0.35)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = const Color(0xFF81C784).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    // Subtle decorative vine tendrils along the corners
    final leftVine = Path()
      ..moveTo(rect.left + 10, rect.top + 40)
      ..cubicTo(rect.left + 25, rect.top + 90, rect.left + 8, rect.top + 140, rect.left + 18, rect.top + 200);
    canvas.drawPath(leftVine, vinePaint);

    final rightVine = Path()
      ..moveTo(rect.right - 10, rect.top + 60)
      ..cubicTo(rect.right - 25, rect.top + 120, rect.right - 8, rect.top + 180, rect.right - 20, rect.top + 240);
    canvas.drawPath(rightVine, vinePaint);

    // Leaves
    canvas.drawOval(Rect.fromCenter(center: Offset(rect.left + 20, rect.top + 110), width: 8, height: 4), leafPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(rect.right - 22, rect.top + 150), width: 8, height: 4), leafPaint);
  }

  static void _paintCandySprinkles(Canvas canvas, Rect rect, MazeThemeConfig theme) {
    final sprinkleColors = [
      const Color(0xFFFF4081),
      const Color(0xFFFFEB3B),
      const Color(0xFF00E5FF),
      const Color(0xFF76FF03),
      const Color(0xFFE040FB),
    ];

    // Seeded sprinkle placements across the board surface
    final random = Random(42);
    for (int i = 0; i < 48; i++) {
      final x = rect.left + 15 + random.nextDouble() * (rect.width - 30);
      final y = rect.top + 30 + random.nextDouble() * (rect.height - 60);
      final angle = random.nextDouble() * pi;
      final color = sprinkleColors[i % sprinkleColors.length];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-4, -1.5, 8, 3),
          const Radius.circular(1.5),
        ),
        Paint()..color = color.withValues(alpha: 0.65),
      );
      canvas.restore();
    }
  }

  static void _paintNebulaVeins(Canvas canvas, Rect rect, MazeThemeConfig theme) {
    final fissurePaint = Paint()
      ..color = const Color(0xFFFF6D00).withValues(alpha: 0.3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFFFFAB40).withValues(alpha: 0.15)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    final fissure = Path()
      ..moveTo(rect.left + 25, rect.top + 140)
      ..lineTo(rect.left + 45, rect.top + 190)
      ..lineTo(rect.left + 35, rect.top + 250)
      ..lineTo(rect.left + 60, rect.top + 320);

    canvas.drawPath(fissure, glowPaint);
    canvas.drawPath(fissure, fissurePaint);
  }

  static void _paintMatte3dPrintTexture(Canvas canvas, Rect rect, MazeThemeConfig theme) {
    // Subtle horizontal extrusion micro-layer lines from 3D printing
    final layerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.0;

    for (double y = rect.top + 4; y < rect.bottom; y += 4.0) {
      canvas.drawLine(Offset(rect.left + 10, y), Offset(rect.right - 10, y), layerPaint);
    }
  }

  // --- Background Void Shaders ---

  static void _paintDustParticlesBackground(Canvas canvas, Size size, double time) {
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final random = Random(128);

    for (int i = 0; i < 30; i++) {
      final bx = random.nextDouble() * size.width;
      final by = (random.nextDouble() * size.height + time * 12.0) % size.height;
      final r = 0.8 + random.nextDouble() * 1.6;
      final alpha = 0.15 + 0.35 * sin(time * 2.0 + i);

      particlePaint.color = const Color(0xFF7DE9FC).withValues(alpha: alpha.clamp(0.05, 0.7));
      canvas.drawCircle(Offset(bx, by), r, particlePaint);
    }
  }

  static void _paintCitySkylineBackground(Canvas canvas, Size size, double time) {
    final buildingPaint = Paint()
      ..color = const Color(0xFF0F0724).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Distant cyber towers
    canvas.drawRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.35, 45, size.height * 0.65), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.45, size.height * 0.25, 55, size.height * 0.75), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.70, size.height * 0.40, 50, size.height * 0.60), buildingPaint);

    // Glowing window grids
    for (double y = size.height * 0.4; y < size.height * 0.8; y += 16) {
      canvas.drawRect(Rect.fromLTWH(size.width * 0.48, y, 4, 6), windowPaint);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.54, y, 4, 6), windowPaint);
    }
  }

  static void _paintRotatingClockworkBackground(Canvas canvas, Size size, double time) {
    final gearPaint = Paint()
      ..color = const Color(0xFF5E3C18).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Animated rotating gears visible in the dark background behind cutout holes
    _drawGear(canvas, Offset(size.width * 0.35, size.height * 0.45), 36, 12, time * 0.4, gearPaint);
    _drawGear(canvas, Offset(size.width * 0.65, size.height * 0.60), 48, 16, -time * 0.3, gearPaint);
  }

  static void _drawGear(Canvas canvas, Offset center, double radius, int teeth, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawCircle(Offset.zero, radius, paint);

    for (int i = 0; i < teeth; i++) {
      final a = (i * 2 * pi) / teeth;
      final x1 = cos(a) * (radius - 3);
      final y1 = sin(a) * (radius - 3);
      final x2 = cos(a) * (radius + 6);
      final y2 = sin(a) * (radius + 6);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
    canvas.restore();
  }

  static void _paintRainforestCanopyBackground(Canvas canvas, Size size, double time) {
    final leafPaint = Paint()
      ..color = const Color(0xFF13280F).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Big silhouetted tropical leaves
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.2, size.height * 0.3), width: 120, height: 60),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.8, size.height * 0.55), width: 140, height: 70),
      leafPaint,
    );
  }

  static void _paintCandyCloudsBackground(Canvas canvas, Size size, double time) {
    final cloudPaint = Paint()
      ..color = const Color(0xFFFF80AB).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 60, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 80, cloudPaint);
  }

  static void _paintGalaxyNebulaBackground(Canvas canvas, Size size, double time) {
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE040FB).withValues(alpha: 0.25),
          const Color(0xFF7C4DFF).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.5), radius: 140));

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 140, nebulaPaint);

    // Stars
    final starPaint = Paint()..color = Colors.white;
    final random = Random(99);
    for (int i = 0; i < 40; i++) {
      final sx = random.nextDouble() * size.width;
      final sy = random.nextDouble() * size.height;
      final twinkle = 0.5 + 0.5 * sin(time * 3.0 + i);
      starPaint.color = Colors.white.withValues(alpha: (0.3 + 0.7 * twinkle).clamp(0.1, 1.0));
      canvas.drawCircle(Offset(sx, sy), 0.7 + random.nextDouble() * 0.8, starPaint);
    }
  }
}
