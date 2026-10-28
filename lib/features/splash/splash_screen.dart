/// Splash screen — initializes services, audio, and storage while showing
/// an atmospheric neon glowing arcade startup animation for BALANCE RUNNER.
library;

import 'package:flutter/material.dart';
import '../../core/services/game_service.dart';
import '../home/home_screen.dart';

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
      duration: const Duration(milliseconds: 2000),
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

    // Delay for splash animation
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => HomeScreen(
          gameService: widget.gameService,
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
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
      backgroundColor: const Color(0xFF061019),
      body: Stack(
        children: [
          // Background ambient gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.1),
                radius: 1.2,
                colors: [
                  Color(0xFF0D253A),
                  Color(0xFF071422),
                  Color(0xFF03070E),
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
                    // 3D Neon "BALANCE"
                    Text(
                      'BALANCE',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6.0,
                        color: Colors.white,
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

                    // 3D Neon "RUNNER"
                    Text(
                      'RUNNER',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                        color: const Color(0xFF5CF3FF),
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: _glowAnimation.value),
                            blurRadius: 32 * _glowAnimation.value,
                          ),
                          Shadow(
                            color: const Color(0xFF0080FF).withValues(alpha: 0.8),
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

                    const SizedBox(height: 36),

                    // Balancing rod & rolling marble animation
                    SizedBox(
                      width: 240,
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow behind the rod
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: _glowAnimation.value * 0.4),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: _glowAnimation.value * 0.8),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),

                          // Metallic Rod
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5CF3FF), Color(0xFF00E5FF), Color(0xFF006064)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),

                          // Rolling Metallic Marble
                          Transform.translate(
                            offset: Offset(_marbleXAnimation.value * 0.6, -14),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  center: Alignment(-0.35, -0.4),
                                  radius: 0.9,
                                  colors: [
                                    Colors.white,
                                    Color(0xFFE2E8F0),
                                    Color(0xFF94A3B8),
                                    Color(0xFF334155),
                                  ],
                                  stops: [0.0, 0.35, 0.7, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Align(
                                alignment: const Alignment(-0.4, -0.4),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // "INITIALIZING CYBER TRACK..."
                    Text(
                      'INITIALIZING CYBER TRACK...',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.0,
                        color: const Color(0xFF00E5FF).withValues(alpha: _glowAnimation.value),
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                            blurRadius: 12,
                          ),
                        ],
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
