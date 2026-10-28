/// Splash screen — initializes services, audio, and storage while showing
/// an atmospheric neon glowing arcade startup animation.
library;

import 'package:flutter/material.dart';
import '../../core/services/game_service.dart';
import '../gameplay/gameplay_screen.dart';

class SplashScreen extends StatefulWidget {
  final GameService gameService;

  const SplashScreen({super.key, required this.gameService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _marbleXAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _marbleXAnimation = Tween<double>(begin: -150.0, end: 150.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOutCubic),
      ),
    );

    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    _controller.forward();
    await widget.gameService.initialize();

    // Small delay to let splash animation breathe
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final startingLevel = (widget.gameService.playerData.highestLevelCompleted + 1).clamp(1, 6);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => GameplayScreen(
          gameService: widget.gameService,
          levelId: startingLevel,
          startInMenu: true,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // Background ambient gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.1),
                radius: 1.2,
                colors: [
                  Color(0xFF0F2B48),
                  Color(0xFF0A1628),
                  Color(0xFF050B14),
                ],
              ),
            ),
          ),

          // Central title & marble
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 3D Neon "BALANCING"
                    Text(
                      'BALANCING',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6.0,
                        color: const Color(0xFF00E5FF),
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: _glowAnimation.value),
                            blurRadius: 28 * _glowAnimation.value,
                          ),
                          Shadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                            blurRadius: 10,
                          ),
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // 3D Neon "MAZE"
                    Text(
                      'MAZE',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                        color: const Color(0xFFFFAB40),
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFF9100).withValues(alpha: _glowAnimation.value),
                            blurRadius: 32 * _glowAnimation.value,
                          ),
                          Shadow(
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.8),
                            blurRadius: 12,
                          ),
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Balancing Rod & Rolling Marble Animation
                    SizedBox(
                      width: 320,
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // The Bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00E5FF),
                                  Color(0xFF80DEEA),
                                  Color(0xFF00E5FF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),

                          // The Marble
                          Transform.translate(
                            offset: Offset(_marbleXAnimation.value, -14),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  center: Alignment(-0.3, -0.3),
                                  colors: [
                                    Colors.white,
                                    Color(0xFFCFD8DC),
                                    Color(0xFF78909C),
                                  ],
                                  stops: [0.0, 0.4, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    blurRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Loading indicator
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
