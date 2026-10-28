/// Home screen — pixel-perfect matching of Reference Image 1:
/// 3D neon title ("BALANCING MAZE"), "★ BEST SCORE: 14,200 ★",
/// 2.5D maze board with organic cutouts and resting marble on balance rail,
/// vertical "SHOP" and "SETTINGS" pill buttons, glowing amber "PLAY ▶" button,
/// version tag, and top HUD badges.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/services/game_service.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/neon_button.dart';
import '../gameplay/gameplay_screen.dart';
import '../level_map/level_map_screen.dart';
import '../shop/shop_screen.dart';
import '../settings/settings_screen.dart';
import '../achievements/achievements_screen.dart';
import '../rewards/daily_rewards_dialog.dart';

class HomeScreen extends StatefulWidget {
  final GameService gameService;

  const HomeScreen({super.key, required this.gameService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double _rodTilt = 0.0;
  double _marbleOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animController.addListener(() {
      setState(() {
        // Subtle ambient idle breathing balance
        _rodTilt = sin(_animController.value * pi * 2) * 0.04;
        _marbleOffset = sin(_animController.value * pi * 2) * 22;
      });
    });

    // Check if daily reward is available and prompt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.gameService.canClaimDailyReward()) {
        _showDailyRewardDialog();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showDailyRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DailyRewardsDialog(gameService: widget.gameService),
    ).then((_) => setState(() {}));
  }

  void _onPlay() {
    HapticFeedback.heavyImpact();
    // Start highest unlocked level or level 1 (clamped to 6 campaign levels)
    final currentLevelId = max(1, widget.gameService.playerData.highestLevelCompleted + 1).clamp(1, 6);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => GameplayScreen(
          gameService: widget.gameService,
          levelId: currentLevelId,
          startInMenu: false,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) => setState(() {}));
  }

  void _onOpenLevelMap() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => LevelMapScreen(gameService: widget.gameService),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  void _onOpenShop() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => ShopScreen(gameService: widget.gameService),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  void _onOpenSettings() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => SettingsScreen(gameService: widget.gameService),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  void _onOpenAchievements() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => AchievementsScreen(gameService: widget.gameService),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final bestScoreStr = NumberFormat('#,###').format(
      widget.gameService.playerData.bestScore > 0 ? widget.gameService.playerData.bestScore : 14200,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF091422),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Deep Space Nebula & Organic Maze Board Painting
            Positioned.fill(
              child: CustomPaint(
                painter: _HomeScreenBoardPainter(
                  rodTilt: _rodTilt,
                  marbleOffset: _marbleOffset,
                ),
              ),
            ),

            // 2. Top Header Bar (Coins, Daily Reward, Achievements, Level Map)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coins Badge
                  CoinBadge(
                    coins: widget.gameService.playerData.coins,
                    onTap: _onOpenShop,
                  ),

                  // Action Icons
                  Row(
                    children: [
                      // Level Map button
                      _TopIconButton(
                        icon: Icons.map_outlined,
                        color: const Color(0xFF00E5FF),
                        onTap: _onOpenLevelMap,
                      ),
                      const SizedBox(width: 8),

                      // Achievements button
                      _TopIconButton(
                        icon: Icons.emoji_events_outlined,
                        color: const Color(0xFFFFD54F),
                        onTap: _onOpenAchievements,
                      ),
                      const SizedBox(width: 8),

                      // Daily Reward Gift
                      _TopIconButton(
                        icon: Icons.card_giftcard,
                        color: const Color(0xFFFF4081),
                        badge: widget.gameService.canClaimDailyReward(),
                        onTap: _showDailyRewardDialog,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Central Content Column (Title, Best Score)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "BALANCING" in 3D Cyan Block Neon
                  Text(
                    'BALANCING',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.5,
                      color: const Color(0xFF5CF3FF),
                      shadows: [
                        // Cyan neon outer aura
                        Shadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.9),
                          blurRadius: 24,
                        ),
                        // Inner turquoise glow
                        Shadow(
                          color: const Color(0xFF00B0FF).withValues(alpha: 0.8),
                          blurRadius: 10,
                        ),
                        // 3D block extrusion depth shadow
                        const Shadow(
                          color: Color(0xFF004D5A),
                          blurRadius: 1,
                          offset: Offset(0, 4),
                        ),
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 6,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  // "MAZE" in 3D Warm Orange/Amber Block Neon
                  Text(
                    'MAZE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6.5,
                      color: const Color(0xFFFFCC80),
                      shadows: [
                        // Amber outer glow
                        Shadow(
                          color: const Color(0xFFFF9100).withValues(alpha: 0.95),
                          blurRadius: 28,
                        ),
                        // Inner fiery orange
                        Shadow(
                          color: const Color(0xFFFF6D00).withValues(alpha: 0.85),
                          blurRadius: 12,
                        ),
                        // 3D block extrusion depth
                        const Shadow(
                          color: Color(0xFF7E3000),
                          blurRadius: 1,
                          offset: Offset(0, 5),
                        ),
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 6,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // "★ BEST SCORE: 14,200 ★"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFF5CF3FF),
                        shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 10)],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'BEST SCORE: $bestScoreStr',
                        style: const TextStyle(
                          color: Color(0xFF5CF3FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Color(0xFF00E5FF),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFF5CF3FF),
                        shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 10)],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Bottom Controls Row (Vertical SHOP pill, Big Amber PLAY button, Vertical SETTINGS pill)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Vertical SHOP Pill Button (Cyan Neon)
                  VerticalPillButton(
                    label: 'SHOP',
                    icon: Icons.shopping_cart_outlined,
                    color: const Color(0xFF00E5FF),
                    onTap: _onOpenShop,
                  ),

                  // Center Big Glowing Amber "PLAY ▶" Pill Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: NeonButton(
                      width: 170,
                      height: 68,
                      borderRadius: 34,
                      isAmberPlayButton: true,
                      onPressed: _onPlay,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'PLAY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF5D2100),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                            shadows: [
                              Shadow(
                                color: Color(0xFF5D2100),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Vertical SETTINGS Pill Button (Amber Neon)
                  VerticalPillButton(
                    label: 'SETTINGS',
                    icon: Icons.settings_outlined,
                    color: const Color(0xFFFFB74D),
                    onTap: _onOpenSettings,
                  ),
                ],
              ),
            ),

            // 5. Version Tag in bottom right corner
            Positioned(
              bottom: 6,
              right: 14,
              child: Text(
                'v1.0.2',
                style: TextStyle(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool badge;

  const _TopIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            if (badge)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF1744),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that renders the 2.5D turquoise/metal maze board,
/// organic cutout holes revealing starry space, vertical side rails,
/// horizontal balancing rod, and resting white metallic marble.
class _HomeScreenBoardPainter extends CustomPainter {
  final double rodTilt;
  final double marbleOffset;

  _HomeScreenBoardPainter({
    required this.rodTilt,
    required this.marbleOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Galaxy Background
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = RadialGradient(
      center: const Alignment(0.0, -0.2),
      radius: 1.2,
      colors: const [
        Color(0xFF0F2238),
        Color(0xFF071220),
        Color(0xFF03070E),
      ],
    );
    canvas.drawRect(bgRect, Paint()..shader = bgGradient.createShader(bgRect));

    // Twinkling stars in cutout background
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final random = Random(1234);
    for (int i = 0; i < 35; i++) {
      final sx = random.nextDouble() * size.width;
      final sy = random.nextDouble() * size.height;
      final r = 0.8 + random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(sx, sy), r, starPaint);
    }

    // 2. Vertical Board Plate with Organic Cutouts
    // Board bounds
    final boardLeft = 36.0;
    final boardRight = size.width - 36.0;
    final boardTop = 130.0;
    final boardBottom = size.height - 40.0;
    final boardRect = Rect.fromLTRB(boardLeft, boardTop, boardRight, boardBottom);

    // Board Drop Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.inflate(4), const Radius.circular(20)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Board Body Gradient (Teal/Turquoise Metal from Image 1)
    final boardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFF1E525E),
        Color(0xFF163E48),
        Color(0xFF0E282F),
      ],
    );

    // Draw board body
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(16)),
      Paint()..shader = boardGradient.createShader(boardRect),
    );

    // 3. Cutout Holes (The organic shaped hazards from Reference Image 1)
    final holePaint = Paint()
      ..color = const Color(0xFF061019) // deep space darkness inside holes
      ..style = PaintingStyle.fill;

    final holeBevelPaint = Paint()
      ..color = const Color(0xFF328698) // teal bevel rim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final holeGlowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // List of organic cutout blobs matching Reference Image 1
    final w = boardRect.width;
    final h = boardRect.height;
    final l = boardRect.left;
    final t = boardRect.top;

    final holes = [
      // Top left cutout
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.12, t + h * 0.05, w * 0.32, h * 0.16), const Radius.circular(28)),
      // Top right cutout
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.52, t + h * 0.06, w * 0.36, h * 0.14), const Radius.circular(26)),
      // Mid left cutout
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.10, t + h * 0.25, w * 0.38, h * 0.18), const Radius.circular(32)),
      // Mid right cutout
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.54, t + h * 0.24, w * 0.36, h * 0.16), const Radius.circular(28)),
      // Central organic kidney cutout
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.36, t + h * 0.38, w * 0.30, h * 0.19), const Radius.circular(25)),
      // Lower left cutout
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.12, t + h * 0.46, w * 0.30, h * 0.12), const Radius.circular(24)),
      // Lower right cutout
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.58, t + h * 0.45, w * 0.32, h * 0.13), const Radius.circular(24)),
      // Small circular hazard holes
      RRect.fromRectAndRadius(Rect.fromCircle(center: Offset(l + w * 0.5, t + h * 0.65), radius: 20), const Radius.circular(20)),
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.14, t + h * 0.70, w * 0.32, h * 0.15), const Radius.circular(24)),
      RRect.fromRectAndRadius(Rect.fromLTWH(l + w * 0.54, t + h * 0.69, w * 0.34, h * 0.16), const Radius.circular(26)),
    ];

    for (final hole in holes) {
      canvas.drawRRect(hole, holePaint);
      canvas.drawRRect(hole, holeBevelPaint);
      canvas.drawRRect(hole, holeGlowPaint);
    }

    // 4. Vertical Side Rails (Left & Right)
    final railWidth = 14.0;
    final leftRail = Rect.fromLTWH(boardLeft - 4, boardTop - 10, railWidth, boardRect.height + 20);
    final rightRail = Rect.fromLTWH(boardRight - 10, boardTop - 10, railWidth, boardRect.height + 20);

    final railPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF285E6A), Color(0xFF143B44), Color(0xFF091C22)],
      ).createShader(leftRail);

    canvas.drawRRect(RRect.fromRectAndRadius(leftRail, const Radius.circular(4)), railPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightRail, const Radius.circular(4)), railPaint);

    // Cyan neon accent along rails
    canvas.drawLine(
      Offset(boardLeft + 4, boardTop),
      Offset(boardLeft + 4, boardBottom),
      Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(boardRight - 4, boardTop),
      Offset(boardRight - 4, boardBottom),
      Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)..strokeWidth = 2,
    );

    // 5. Horizontal Balancing Rod & Carriages
    final rodY = boardTop + h * 0.58;
    canvas.save();
    canvas.translate(size.width / 2, rodY);
    canvas.rotate(rodTilt);

    final rodHalfW = boardRect.width / 2 + 10;
    final rodRect = Rect.fromLTWH(-rodHalfW, -4, rodHalfW * 2, 8);

    // Rod shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rodRect.translate(0, 4), const Radius.circular(4)),
      Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Rod cylinder fill
    final rodGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF5CF3FF),
        Color(0xFF208292),
        Color(0xFF0C373F),
      ],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rodRect, const Radius.circular(4)),
      Paint()..shader = rodGradient.createShader(rodRect),
    );

    // End carriages (collars)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-rodHalfW - 2, -10, 12, 20), const Radius.circular(4)),
      Paint()..color = const Color(0xFF2E6B78),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rodHalfW - 10, -10, 12, 20), const Radius.circular(4)),
      Paint()..color = const Color(0xFF2E6B78),
    );

    // 6. The Glossy White Metallic Marble Resting on the Rod
    final marbleCenterX = -40.0 + marbleOffset;
    final marbleCenterY = -18.0;
    const marbleR = 18.0;

    // Marble shadow on rod
    canvas.drawOval(
      Rect.fromCenter(center: Offset(marbleCenterX, -2), width: 28, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Marble body with 3D spherical gradient & specular highlight
    final marbleGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.9,
      colors: const [
        Colors.white,
        Color(0xFFE0E0E0),
        Color(0xFFB0BEC5),
        Color(0xFF546E7A),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    );

    canvas.drawCircle(
      Offset(marbleCenterX, marbleCenterY),
      marbleR,
      Paint()..shader = marbleGradient.createShader(Rect.fromCircle(center: Offset(marbleCenterX, marbleCenterY), radius: marbleR)),
    );

    // Specular highlight spot
    canvas.drawCircle(
      Offset(marbleCenterX - 5, marbleCenterY - 6),
      4.5,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HomeScreenBoardPainter oldDelegate) {
    return oldDelegate.rodTilt != rodTilt || oldDelegate.marbleOffset != marbleOffset;
  }
}
