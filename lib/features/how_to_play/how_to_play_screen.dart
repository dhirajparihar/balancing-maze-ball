/// How to Play screen — matches Reference Screen 2:
/// Step 1: "Drag left end up or down to tilt the bar"
/// Step 2: "Drag right end up or down to tilt the bar"
/// Step 3: "Keep the ball balanced while the board moves downwards."
/// 3 interactive visual diagrams, pager dots, and "GOT IT!" cyan button.
library;

import 'package:flutter/material.dart';
import '../../core/services/game_service.dart';
import '../gameplay/gameplay_screen.dart';

class HowToPlayScreen extends StatefulWidget {
  final GameService gameService;
  final bool launchGameOnFinish;

  const HowToPlayScreen({
    super.key,
    required this.gameService,
    this.launchGameOnFinish = false,
  });

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGotIt() {
    if (widget.launchGameOnFinish) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim, _) => GameplayScreen(
            gameService: widget.gameService,
          ),
          transitionsBuilder: (context, anim, _, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061019),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00E5FF), size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'HOW TO PLAY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(color: Color(0xFF00E5FF), blurRadius: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 48), // balance back button
              ],
            ),

            const SizedBox(height: 16),

            // Pager cards
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  _TutorialCard(
                    step: 1,
                    title: 'Drag left end up or down to tilt the bar.',
                    tiltLeft: true,
                    tiltRight: false,
                    isMovingBoard: false,
                  ),
                  _TutorialCard(
                    step: 2,
                    title: 'Drag right end up or down to tilt the bar.',
                    tiltLeft: false,
                    tiltRight: true,
                    isMovingBoard: false,
                  ),
                  _TutorialCard(
                    step: 3,
                    title: 'Keep the ball balanced while the board moves downwards.',
                    tiltLeft: false,
                    tiltRight: false,
                    isMovingBoard: true,
                  ),
                ],
              ),
            ),

            // Pager Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF00E5FF) : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isActive
                        ? [const BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8)]
                        : null,
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // "GOT IT!" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF00B0FF), Color(0xFF0080FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _onGotIt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
                    ),
                    child: const Text(
                      'GOT IT!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
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

class _TutorialCard extends StatelessWidget {
  final int step;
  final String title;
  final bool tiltLeft;
  final bool tiltRight;
  final bool isMovingBoard;

  const _TutorialCard({
    required this.step,
    required this.title,
    required this.tiltLeft,
    required this.tiltRight,
    required this.isMovingBoard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1826),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustrated Canvas
            SizedBox(
              height: 240,
              width: double.infinity,
              child: CustomPaint(
                painter: _TutorialCardPainter(
                  step: step,
                  tiltLeft: tiltLeft,
                  tiltRight: tiltRight,
                  isMovingBoard: isMovingBoard,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instruction Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialCardPainter extends CustomPainter {
  final int step;
  final bool tiltLeft;
  final bool tiltRight;
  final bool isMovingBoard;

  _TutorialCardPainter({
    required this.step,
    required this.tiltLeft,
    required this.tiltRight,
    required this.isMovingBoard,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + (isMovingBoard ? 20 : 0);

    // Track rails on left and right
    final railLeft = cx - 110.0;
    final railRight = cx + 110.0;
    final railPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)
      ..strokeWidth = 3;

    canvas.drawLine(Offset(railLeft, 20), Offset(railLeft, size.height - 20), railPaint);
    canvas.drawLine(Offset(railRight, 20), Offset(railRight, size.height - 20), railPaint);

    if (isMovingBoard) {
      // Draw organic cutout holes moving down with downward motion arrows
      final holePaint = Paint()..color = const Color(0xFF040A10);
      final holeRim = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final h1 = RRect.fromRectAndRadius(Rect.fromLTWH(railLeft + 12, 35, 65, 45), const Radius.circular(16));
      final h2 = RRect.fromRectAndRadius(Rect.fromLTWH(railRight - 75, 45, 60, 40), const Radius.circular(14));
      canvas.drawRRect(h1, holePaint);
      canvas.drawRRect(h1, holeRim);
      canvas.drawRRect(h2, holePaint);
      canvas.drawRRect(h2, holeRim);

      // Downward chevron arrows
      final arrowPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.7)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < 3; i++) {
        final ay = 95.0 + i * 20.0;
        final path = Path()
          ..moveTo(cx - 14, ay - 6)
          ..lineTo(cx, ay + 6)
          ..lineTo(cx + 14, ay - 6);
        canvas.drawPath(path, arrowPaint);
      }
    }

    // Balance Bar
    final angle = tiltLeft ? -0.25 : (tiltRight ? 0.25 : 0.0);
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    const barW = 180.0;
    final barRect = Rect.fromCenter(center: Offset.zero, width: barW, height: 10);
    final barGradient = const LinearGradient(
      colors: [Color(0xFF80DEEA), Color(0xFF00E5FF), Color(0xFF006064)],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(5)),
      Paint()..shader = barGradient.createShader(barRect),
    );

    // End handles
    canvas.drawCircle(Offset(-barW / 2, 0), 10, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(barW / 2, 0), 10, Paint()..color = const Color(0xFF00E5FF));

    // Ball on the bar
    final ballX = tiltLeft ? -45.0 : (tiltRight ? 45.0 : 0.0);
    const ballR = 14.0;
    final ballCenter = Offset(ballX, -ballR - 4);

    final ballGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.9,
      colors: const [Colors.white, Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
    );
    canvas.drawCircle(
      ballCenter,
      ballR,
      Paint()..shader = ballGradient.createShader(Rect.fromCircle(center: ballCenter, radius: ballR)),
    );
    canvas.drawCircle(
      Offset(ballCenter.dx - 4, ballCenter.dy - 4),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    canvas.restore();

    // Finger / Drag Arrows
    if (tiltLeft) {
      _drawVerticalArrows(canvas, Offset(cx - 90, cy - 35), true);
    } else if (tiltRight) {
      _drawVerticalArrows(canvas, Offset(cx + 90, cy - 35), false);
    }
  }

  void _drawVerticalArrows(Canvas canvas, Offset pos, bool isLeft) {
    final arrowPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Up and down arrows
    final p1 = Path()
      ..moveTo(pos.dx - 8, pos.dy - 16)
      ..lineTo(pos.dx, pos.dy - 28)
      ..lineTo(pos.dx + 8, pos.dy - 16);
    canvas.drawPath(p1, arrowPaint);

    final p2 = Path()
      ..moveTo(pos.dx - 8, pos.dy + 86)
      ..lineTo(pos.dx, pos.dy + 98)
      ..lineTo(pos.dx + 8, pos.dy + 86);
    canvas.drawPath(p2, arrowPaint);

    canvas.drawLine(Offset(pos.dx, pos.dy - 28), Offset(pos.dx, pos.dy + 98), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _TutorialCardPainter oldDelegate) => false;
}
