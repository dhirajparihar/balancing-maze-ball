/// Shop Overlay — matches Reference Image 5:
/// Top bar with back button, "SKIN & COLOR SHOP" neon title, coin balance pill,
/// live theme board preview, horizontal theme carousel with EQUIPPED / UNLOCK badges,
/// and bottom tab selector (BOARD THEMES, BALL SKINS, KNOB STYLES).
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/game_providers.dart';
import '../../../game/balancing_maze_game.dart';
import '../../../models/maze_theme_config.dart';

class ShopThemeSelectorSheet extends ConsumerStatefulWidget {
  final BalancingMazeGame game;
  final VoidCallback onClose;

  const ShopThemeSelectorSheet({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  ConsumerState<ShopThemeSelectorSheet> createState() => _ShopThemeSelectorSheetState();
}

class _ShopThemeSelectorSheetState extends ConsumerState<ShopThemeSelectorSheet> {
  int _selectedTabIndex = 0; // 0: BOARD THEMES, 1: BALL SKINS, 2: KNOB STYLES
  late MazeThemeConfig _previewTheme;

  final List<String> _tabs = ['BOARD THEMES', 'BALL SKINS', 'KNOB STYLES'];

  @override
  void initState() {
    super.initState();
    _previewTheme = widget.game.currentTheme;
  }

  void _selectTheme(MazeThemeConfig theme) {
    setState(() {
      _previewTheme = theme;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _equipTheme(MazeThemeConfig theme) async {
    ref.read(mazeThemeProvider.notifier).selectTheme(theme);
    widget.game.switchTheme(theme);
    widget.game.gameService.playerData.selectedThemeId = theme.id;
    await widget.game.gameService.save();
    setState(() {
      _previewTheme = theme;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _purchaseTheme(MazeThemeConfig theme) async {
    final success = await widget.game.gameService.spendCoins(theme.unlockCost);
    if (success) {
      widget.game.gameService.playerData.ownedItems.add('theme_${theme.id}');
      await _equipTheme(theme);
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Not enough coins! Play levels to earn more.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFFF5252),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  bool _isOwned(MazeThemeConfig theme) {
    if (theme.isDefault || theme.unlockCost == 0) return true;
    return widget.game.gameService.playerData.ownedItems.contains('theme_${theme.id}');
  }

  bool _isEquipped(MazeThemeConfig theme) {
    return widget.game.currentTheme.id == theme.id;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final coins = widget.game.gameService.playerData.coins;
    final formattedCoins = NumberFormat('#,###').format(coins);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Dark frosted glass background backdrop
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: const Color(0xFF070410).withValues(alpha: 0.92),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back Button [←]
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onClose();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFF161F33).withValues(alpha: 0.8),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFFE0F7FA),
                            size: 22,
                          ),
                        ),
                      ),

                      // Title: SKIN & COLOR / SHOP
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SKIN & COLOR',
                              style: TextStyle(
                                color: const Color(0xFFFFD54F),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFFFB300).withValues(alpha: 0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'SHOP',
                              style: TextStyle(
                                color: const Color(0xFFFF4081),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.5,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFE040FB).withValues(alpha: 0.9),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Coin Balance Pill: [12,450 🪙]
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFF13192B),
                          border: Border.all(
                            color: const Color(0xFFFFD54F).withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formattedCoins,
                              style: const TextStyle(
                                color: Color(0xFFFFECB3),
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [Color(0xFFFFEE58), Color(0xFFFF8F00)],
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'C',
                                  style: TextStyle(
                                    color: Color(0xFF3E2723),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Center Board Preview Area
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      child: AspectRatio(
                        aspectRatio: 40.0 / 70.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _previewTheme.rimColor.withValues(alpha: 0.8),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _previewTheme.rimGlowColor.withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.7),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: CustomPaint(
                              painter: _ShopBoardPreviewPainter(theme: _previewTheme),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Horizontal Theme Carousel (Matching Reference Image 5)
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: MazeThemeConfig.allThemes.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final theme = MazeThemeConfig.allThemes[index];
                      final isSelected = _previewTheme.id == theme.id;
                      final isEquipped = _isEquipped(theme);
                      final isOwned = _isOwned(theme);

                      return _buildThemeCard(
                        theme: theme,
                        isSelected: isSelected,
                        isEquipped: isEquipped,
                        isOwned: isOwned,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Bottom Tab Selector (BOARD THEMES, BALL SKINS, KNOB STYLES)
                Container(
                  height: 48,
                  margin: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: bottomPadding > 0 ? bottomPadding : 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101726).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final isTabSelected = _selectedTabIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedTabIndex = index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: isTabSelected
                                  ? Border(
                                      bottom: BorderSide(
                                        color: const Color(0xFFFFB74D),
                                        width: 3.0,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                _tabs[index],
                                style: TextStyle(
                                  color: isTabSelected
                                      ? const Color(0xFFFFB74D)
                                      : const Color(0xFF90A4AE),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  shadows: isTabSelected
                                      ? [
                                          Shadow(
                                            color: const Color(0xFFFFB74D).withValues(alpha: 0.7),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required MazeThemeConfig theme,
    required bool isSelected,
    required bool isEquipped,
    required bool isOwned,
  }) {
    return GestureDetector(
      onTap: () => _selectTheme(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 115,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF13192B),
          border: Border.all(
            color: isEquipped
                ? const Color(0xFFFFD54F)
                : isSelected
                    ? const Color(0xFF00E5FF)
                    : const Color(0xFF263238),
            width: isEquipped || isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isEquipped
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                    blurRadius: 14,
                  ),
                ]
              : isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
        ),
        child: Column(
          children: [
            // Mini board cutout preview
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  color: theme.voidBgColor,
                  child: CustomPaint(
                    painter: _MiniBoardPainter(theme: theme),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // Theme Name
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2, left: 4, right: 4),
              child: Text(
                theme.name.replaceAll(' ', '\n'),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: Color(0xFFECEFF1),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  height: 1.1,
                ),
              ),
            ),

            // Action Button: EQUIPPED / EQUIP / 🪙 2,500
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: SizedBox(
                width: double.infinity,
                height: 24,
                child: isEquipped
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFB300).withValues(alpha: 0.25),
                              const Color(0xFFFF8F00).withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'EQUIPPED',
                            style: TextStyle(
                              color: Color(0xFFFFECB3),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      )
                    : isOwned
                        ? GestureDetector(
                            onTap: () => _equipTheme(theme),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                                border: Border.all(color: const Color(0xFF00E5FF), width: 1.0),
                              ),
                              child: const Center(
                                child: Text(
                                  'EQUIP',
                                  style: TextStyle(
                                    color: Color(0xFFE0F7FA),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _purchaseTheme(theme),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                                border: Border.all(
                                  color: const Color(0xFFFFD54F).withValues(alpha: 0.8),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.monetization_on_rounded,
                                      color: Color(0xFFFFD54F), size: 10),
                                  const SizedBox(width: 3),
                                  Text(
                                    NumberFormat('#,###').format(theme.unlockCost),
                                    style: const TextStyle(
                                      color: Color(0xFFFFECB3),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini board painter for cards in carousel
class _MiniBoardPainter extends CustomPainter {
  final MazeThemeConfig theme;

  const _MiniBoardPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final facePaint = Paint()..color = theme.boardFaceColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 4),
        const Radius.circular(6),
      ),
      facePaint,
    );

    // Rails
    final railPaint = Paint()..color = theme.railColor;
    canvas.drawRect(Rect.fromLTWH(6, 4, 3, size.height - 4), railPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 9, 4, 3, size.height - 4), railPaint);

    // Mini cutout holes
    final holePaint = Paint()..color = theme.voidBgColor;
    final rimPaint = Paint()
      ..color = theme.rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    void drawHole(Offset c, double r) {
      canvas.drawCircle(c, r, holePaint);
      canvas.drawCircle(c, r, rimPaint);
    }

    drawHole(Offset(size.width * 0.5, size.height * 0.22), 6);
    drawHole(Offset(size.width * 0.32, size.height * 0.45), 8);
    drawHole(Offset(size.width * 0.68, size.height * 0.50), 9);
    drawHole(Offset(size.width * 0.45, size.height * 0.75), 7);
  }

  @override
  bool shouldRepaint(covariant _MiniBoardPainter oldDelegate) =>
      oldDelegate.theme.id != theme.id;
}

/// Full interactive preview painter of the board matching Reference Image 5
class _ShopBoardPreviewPainter extends CustomPainter {
  final MazeThemeConfig theme;

  const _ShopBoardPreviewPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw void background
    final voidPaint = Paint()..color = theme.voidBgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), voidPaint);

    // 2. Draw Faceplate board
    final boardMargin = size.width * 0.08;
    final boardRect = Rect.fromLTWH(
      boardMargin,
      size.height * 0.05,
      size.width - (boardMargin * 2),
      size.height * 0.90,
    );

    final facePaint = Paint()..color = theme.boardFaceColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(16)),
      facePaint,
    );

    // 3. Draw Side Rails
    final railWidth = size.width * 0.05;
    final leftRailRect = Rect.fromLTWH(
      boardMargin,
      boardRect.top,
      railWidth,
      boardRect.height,
    );
    final rightRailRect = Rect.fromLTWH(
      boardRect.right - railWidth,
      boardRect.top,
      railWidth,
      boardRect.height,
    );

    final railPaint = Paint()..color = theme.railColor;
    canvas.drawRect(leftRailRect, railPaint);
    canvas.drawRect(rightRailRect, railPaint);

    // Rail highlights
    final railHighlightPaint = Paint()..color = theme.railHighlightColor.withValues(alpha: 0.6);
    canvas.drawLine(
      Offset(leftRailRect.left + 1, leftRailRect.top),
      Offset(leftRailRect.left + 1, leftRailRect.bottom),
      railHighlightPaint,
    );
    canvas.drawLine(
      Offset(rightRailRect.right - 1, rightRailRect.top),
      Offset(rightRailRect.right - 1, rightRailRect.bottom),
      railHighlightPaint,
    );

    // 4. Organic Hole Cutouts
    final holePaint = Paint()..color = theme.voidBgColor;
    final rimPaint = Paint()
      ..color = theme.rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rimGlowPaint = Paint()
      ..color = theme.rimGlowColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, theme.rimGlowSigma);

    void drawOrganicCutout(Path path) {
      canvas.drawPath(path, holePaint);
      canvas.drawPath(path, rimGlowPaint);
      canvas.drawPath(path, rimPaint);
    }

    final scaleX = size.width / 40.0;
    final scaleY = size.height / 75.0;

    // Top Goal Hole (Circular)
    final goalCenter = Offset(20.0 * scaleX, 19.5 * scaleY);
    final goalRadius = 2.3 * scaleX;
    canvas.drawCircle(goalCenter, goalRadius, holePaint);
    canvas.drawCircle(
      goalCenter,
      goalRadius,
      Paint()
        ..color = theme.targetHoleGlow.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      goalCenter,
      goalRadius,
      Paint()
        ..color = theme.targetHoleColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Organic Shapes: Upper-left kidney, Upper-center oval, etc.
    final p1 = Path()
      ..moveTo(10.0 * scaleX, 23.0 * scaleY)
      ..cubicTo(14.0 * scaleX, 22.0 * scaleY, 17.0 * scaleX, 23.5 * scaleY, 16.5 * scaleX, 29.0 * scaleY)
      ..cubicTo(16.0 * scaleX, 33.0 * scaleY, 12.0 * scaleX, 34.5 * scaleY, 10.5 * scaleX, 31.0 * scaleY)
      ..cubicTo(9.0 * scaleX, 27.5 * scaleY, 8.5 * scaleX, 24.0 * scaleY, 10.0 * scaleX, 23.0 * scaleY)
      ..close();
    drawOrganicCutout(p1);

    final p2 = Path()
      ..moveTo(21.0 * scaleX, 26.0 * scaleY)
      ..cubicTo(27.0 * scaleX, 24.5 * scaleY, 32.0 * scaleX, 27.0 * scaleY, 31.0 * scaleX, 32.0 * scaleY)
      ..cubicTo(29.0 * scaleX, 37.0 * scaleY, 23.0 * scaleX, 36.5 * scaleY, 19.5 * scaleX, 33.0 * scaleY)
      ..cubicTo(18.0 * scaleX, 30.0 * scaleY, 18.5 * scaleX, 27.0 * scaleY, 21.0 * scaleX, 26.0 * scaleY)
      ..close();
    drawOrganicCutout(p2);

    final p3 = Path()
      ..moveTo(12.0 * scaleX, 39.0 * scaleY)
      ..cubicTo(19.0 * scaleX, 37.0 * scaleY, 22.0 * scaleX, 42.0 * scaleY, 19.0 * scaleX, 47.0 * scaleY)
      ..cubicTo(15.5 * scaleX, 51.5 * scaleY, 9.5 * scaleX, 48.0 * scaleY, 10.0 * scaleX, 43.0 * scaleY)
      ..cubicTo(10.5 * scaleX, 40.5 * scaleY, 10.5 * scaleX, 39.5 * scaleY, 12.0 * scaleX, 39.0 * scaleY)
      ..close();
    drawOrganicCutout(p3);

    final p4 = Path()
      ..moveTo(25.0 * scaleX, 40.0 * scaleY)
      ..cubicTo(31.0 * scaleX, 38.5 * scaleY, 32.5 * scaleX, 44.0 * scaleY, 30.5 * scaleX, 49.0 * scaleY)
      ..cubicTo(28.0 * scaleX, 53.0 * scaleY, 23.5 * scaleX, 50.0 * scaleY, 24.0 * scaleX, 44.0 * scaleY)
      ..close();
    drawOrganicCutout(p4);

    final p5 = Path()
      ..moveTo(17.0 * scaleX, 53.0 * scaleY)
      ..cubicTo(24.0 * scaleX, 51.0 * scaleY, 26.0 * scaleX, 57.0 * scaleY, 23.5 * scaleX, 62.0 * scaleY)
      ..cubicTo(21.0 * scaleX, 65.0 * scaleY, 15.5 * scaleX, 63.5 * scaleY, 16.0 * scaleX, 58.0 * scaleY)
      ..close();
    drawOrganicCutout(p5);

    // 5. Lifting Bar
    final barY = 56.0 * scaleY;
    final barPaint = Paint()..color = theme.barBodyColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(leftRailRect.right, barY - 2.5, rightRailRect.left - leftRailRect.right, 5.0),
        const Radius.circular(2.5),
      ),
      barPaint,
    );

    // Pulley cables stretching from top
    final cablePaint = Paint()
      ..color = theme.cableNormalColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(leftRailRect.center.dx, boardRect.top + 10), Offset(leftRailRect.center.dx, barY), cablePaint);
    canvas.drawLine(Offset(rightRailRect.center.dx, boardRect.top + 10), Offset(rightRailRect.center.dx, barY), cablePaint);

    // 6. Glowing Marble on the bar
    final marbleCenter = Offset(16.5 * scaleX, barY - 7.5);
    final marblePaint = Paint()..color = theme.marbleBaseColor;
    if (theme.marbleGlows) {
      canvas.drawCircle(
        marbleCenter,
        8.0,
        Paint()
          ..color = theme.marbleHighlightColor.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawCircle(marbleCenter, 6.0, marblePaint);

    // Marble Specular Dot
    final specPaint = Paint()..color = theme.marbleSpecularColor;
    canvas.drawCircle(marbleCenter + const Offset(-1.8, -1.8), 2.0, specPaint);
  }

  @override
  bool shouldRepaint(covariant _ShopBoardPreviewPainter oldDelegate) =>
      oldDelegate.theme.id != theme.id;
}
