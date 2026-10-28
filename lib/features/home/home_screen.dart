/// Main Menu screen — matches Reference Screen 1:
/// Glowing 3D "BALANCE RUNNER" neon title, metallic ball on glowing halo,
/// PLAY button, CHALLENGE, LEADERBOARD, SKINS, SETTINGS, and tutorial access.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/game_service.dart';
import '../../widgets/coin_badge.dart';
import '../daily_challenge/daily_challenge_screen.dart';
import '../gameplay/gameplay_screen.dart';
import '../how_to_play/how_to_play_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../settings/settings_screen.dart';
import '../skins/skins_screen.dart';

class HomeScreen extends StatefulWidget {
  final GameService gameService;

  const HomeScreen({super.key, required this.gameService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPlay() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => GameplayScreen(
          gameService: widget.gameService,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) => setState(() {}));
  }

  void _onDailyChallenge() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => DailyChallengeScreen(
          gameService: widget.gameService,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  void _onLeaderboard() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => LeaderboardScreen(
          gameService: widget.gameService,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  void _onSkins() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => SkinsScreen(
          gameService: widget.gameService,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  void _onSettings() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => SettingsScreen(
          gameService: widget.gameService,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
  }

  void _onHowToPlay() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => HowToPlayScreen(
          gameService: widget.gameService,
          launchGameOnFinish: false,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061019),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Cyber Space Animation
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _MainMenuBackgroundPainter(animValue: _animController.value),
                  );
                },
              ),
            ),

            // Top Header: Coin Badge & How to Play Button
            Positioned(
              top: 12,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CoinBadge(
                    coins: widget.gameService.playerData.coins,
                    onTap: _onSkins,
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF00E5FF), size: 28),
                    onPressed: _onHowToPlay,
                  ),
                ],
              ),
            ),

            // Central Content: Title, Glowing Ball Halo, and Menu Buttons
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      // "BALANCE" Title
                      const Text(
                        'BALANCE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Color(0xFF00E5FF), blurRadius: 28),
                            Shadow(color: Color(0xFF00B0FF), blurRadius: 14),
                          ],
                        ),
                      ),

                      // "RUNNER" Title
                      const Text(
                        'RUNNER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6.0,
                          color: Color(0xFF5CF3FF),
                          shadows: [
                            Shadow(color: Color(0xFF00E5FF), blurRadius: 32),
                            Shadow(color: Color(0xFF0080FF), blurRadius: 16),
                            Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 4)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Metallic Ball resting on glowing halo
                      SizedBox(
                        height: 110,
                        width: 140,
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _GlowingHaloBallPainter(
                                floatOffset: sin(_animController.value * pi * 2) * 5,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 1. PLAY BUTTON (Big Glowing Cyan Pill)
                      _buildPillButton(
                        label: 'PLAY',
                        icon: Icons.play_arrow_rounded,
                        isPrimary: true,
                        onTap: _onPlay,
                      ),

                      const SizedBox(height: 14),

                      // 2. CHALLENGE BUTTON
                      _buildPillButton(
                        label: 'CHALLENGE',
                        icon: Icons.calendar_today_rounded,
                        isPrimary: false,
                        onTap: _onDailyChallenge,
                      ),

                      const SizedBox(height: 14),

                      // 3. LEADERBOARD BUTTON
                      _buildPillButton(
                        label: 'LEADERBOARD',
                        icon: Icons.emoji_events_rounded,
                        isPrimary: false,
                        onTap: _onLeaderboard,
                      ),

                      const SizedBox(height: 14),

                      // 4. SKINS BUTTON
                      _buildPillButton(
                        label: 'SKINS',
                        icon: Icons.palette_rounded,
                        isPrimary: false,
                        onTap: _onSkins,
                      ),

                      const SizedBox(height: 14),

                      // 5. SETTINGS BUTTON
                      _buildPillButton(
                        label: 'SETTINGS',
                        icon: Icons.settings_rounded,
                        isPrimary: false,
                        onTap: _onSettings,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(31),
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFF00B0FF), Color(0xFF0080FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.65),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(31)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: const Color(0xFF0C2235).withValues(alpha: 0.85),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF00E5FF), size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowingHaloBallPainter extends CustomPainter {
  final double floatOffset;

  _GlowingHaloBallPainter({required this.floatOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;

    // Glowing Cyan Elliptical Halo
    final haloRect = Rect.fromCenter(center: Offset(cx, cy + 18), width: 110, height: 28);
    canvas.drawOval(
      haloRect,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawOval(
      haloRect,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Metallic Ball Floating above Halo
    const ballR = 24.0;
    final ballCenter = Offset(cx, cy - 2 + floatOffset);

    // Ball shadow on halo
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 16), width: 44, height: 12),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Ball spherical gradient
    canvas.drawCircle(
      ballCenter,
      ballR,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          radius: 0.9,
          colors: [Colors.white, Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF334155)],
          stops: [0.0, 0.35, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: ballCenter, radius: ballR)),
    );

    // Specular shine
    canvas.drawCircle(
      Offset(ballCenter.dx - 7, ballCenter.dy - 7),
      5.5,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _GlowingHaloBallPainter oldDelegate) {
    return oldDelegate.floatOffset != floatOffset;
  }
}

class _MainMenuBackgroundPainter extends CustomPainter {
  final double animValue;

  _MainMenuBackgroundPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Deep Space Radial Background
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = RadialGradient(
      center: const Alignment(0, -0.2),
      radius: 1.2,
      colors: const [Color(0xFF0D253A), Color(0xFF071422), Color(0xFF03070E)],
    );
    canvas.drawRect(bgRect, Paint()..shader = bgGradient.createShader(bgRect));

    // Ambient Cyan Light Streaks
    final streakPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.08)
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (int i = 0; i < 6; i++) {
      final x = (size.width / 5) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streakPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MainMenuBackgroundPainter oldDelegate) => true;
}
