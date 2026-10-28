/// Skins / Customization screen — matches Reference Screen 10:
/// Live interactive preview of ball on bar, 8 Ball Skins grid, and 4 Bar Styles.
library;

import 'package:flutter/material.dart';
import '../../core/services/game_service.dart';
import '../../models/balance_runner_models.dart';
import '../../widgets/coin_badge.dart';

class SkinsScreen extends StatefulWidget {
  final GameService gameService;

  const SkinsScreen({super.key, required this.gameService});

  @override
  State<SkinsScreen> createState() => _SkinsScreenState();
}

class _SkinsScreenState extends State<SkinsScreen> {
  late String _equippedBall;
  late String _equippedBar;

  @override
  void initState() {
    super.initState();
    _equippedBall = widget.gameService.playerData.equippedMarbleSkin;
    _equippedBar = widget.gameService.playerData.equippedBarSkin;
  }

  void _onSelectBall(BallSkinDef skin) async {
    final isUnlocked = widget.gameService.isBallSkinUnlocked(skin.id);
    if (isUnlocked) {
      await widget.gameService.equipMarbleSkin(skin.id);
      setState(() => _equippedBall = skin.id);
    } else {
      if (widget.gameService.canAfford(skin.cost)) {
        final success = await widget.gameService.unlockBallSkin(skin.id, skin.cost);
        if (success) {
          setState(() => _equippedBall = skin.id);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Need ${skin.cost} coins to unlock ${skin.name}!'),
            backgroundColor: const Color(0xFF0C273C),
          ),
        );
      }
    }
  }

  void _onSelectBar(BarStyleDef style) async {
    final isUnlocked = widget.gameService.isBarStyleUnlocked(style.id);
    if (isUnlocked) {
      await widget.gameService.equipBarSkin(style.id);
      setState(() => _equippedBar = style.id);
    } else {
      if (widget.gameService.canAfford(style.cost)) {
        final success = await widget.gameService.unlockBarStyle(style.id, style.cost);
        if (success) {
          setState(() => _equippedBar = style.id);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Need ${style.cost} coins to unlock ${style.name}!'),
            backgroundColor: const Color(0xFF0C273C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBallDef = BallSkinDef.getById(_equippedBall);
    final currentBarDef = BarStyleDef.getById(_equippedBar);

    return Scaffold(
      backgroundColor: const Color(0xFF061019),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00E5FF), size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'CUSTOMIZATION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        shadows: [
                          Shadow(color: Color(0xFF00E5FF), blurRadius: 14),
                        ],
                      ),
                    ),
                  ),
                  CoinBadge(coins: widget.gameService.playerData.coins),
                ],
              ),
            ),

            // Live Preview Stage
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1826),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(260, 90),
                  painter: _LivePreviewPainter(
                    ball: currentBallDef,
                    bar: currentBarDef,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // BALL SKINS SECTION
                  const Text(
                    'BALL SKINS',
                    style: TextStyle(
                      color: Color(0xFF5CF3FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: BallSkinDef.allSkins.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final skin = BallSkinDef.allSkins[index];
                      final isEquipped = skin.id == _equippedBall;
                      final isUnlocked = widget.gameService.isBallSkinUnlocked(skin.id);

                      return GestureDetector(
                        onTap: () => _onSelectBall(skin),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2438),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isEquipped
                                  ? const Color(0xFF00E5FF)
                                  : isUnlocked
                                      ? Colors.white24
                                      : Colors.white10,
                              width: isEquipped ? 2.0 : 1.0,
                            ),
                            boxShadow: isEquipped
                                ? [const BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8)]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 3D Sphere Preview
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.35, -0.4),
                                    colors: skin.gradientColors,
                                    stops: skin.stops,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: skin.glowColor.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),

                              // Equipped badge
                              if (isEquipped)
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),

                              // Locked indicator
                              if (!isUnlocked)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.lock, color: Colors.white70, size: 18),
                                        Text(
                                          '${skin.cost}',
                                          style: const TextStyle(
                                            color: Color(0xFFFFD54F),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // BAR STYLES SECTION
                  const Text(
                    'BAR STYLES',
                    style: TextStyle(
                      color: Color(0xFF5CF3FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: BarStyleDef.allStyles.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, index) {
                      final style = BarStyleDef.allStyles[index];
                      final isEquipped = style.id == _equippedBar;
                      final isUnlocked = widget.gameService.isBarStyleUnlocked(style.id);

                      return GestureDetector(
                        onTap: () => _onSelectBar(style),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2438),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isEquipped
                                  ? const Color(0xFF00E5FF)
                                  : isUnlocked
                                      ? Colors.white24
                                      : Colors.white10,
                              width: isEquipped ? 2.0 : 1.0,
                            ),
                            boxShadow: isEquipped
                                ? [const BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8)]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Stylized bar line
                                  Container(
                                    height: 10,
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: LinearGradient(colors: style.rodGradient),
                                      boxShadow: [
                                        BoxShadow(
                                          color: style.glowColor.withValues(alpha: 0.6),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    style.name,
                                    style: TextStyle(
                                      color: isEquipped ? const Color(0xFF00E5FF) : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isUnlocked)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.lock, color: Colors.white70, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${style.cost}',
                                        style: const TextStyle(
                                          color: Color(0xFFFFD54F),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePreviewPainter extends CustomPainter {
  final BallSkinDef ball;
  final BarStyleDef bar;

  _LivePreviewPainter({required this.ball, required this.bar});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;

    // Bar
    final barRect = Rect.fromCenter(center: Offset(cx, cy), width: 200, height: 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(5)),
      Paint()
        ..color = bar.glowColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(5)),
      Paint()..shader = LinearGradient(colors: bar.rodGradient).createShader(barRect),
    );

    // Collars
    canvas.drawCircle(Offset(cx - 100, cy), 8, Paint()..color = bar.primaryColor);
    canvas.drawCircle(Offset(cx + 100, cy), 8, Paint()..color = bar.primaryColor);

    // Ball
    const ballR = 18.0;
    final ballCenter = Offset(cx, cy - ballR - 5);

    canvas.drawCircle(
      ballCenter,
      ballR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.9,
          colors: ball.gradientColors,
          stops: ball.stops,
        ).createShader(Rect.fromCircle(center: ballCenter, radius: ballR)),
    );

    // Specular shine
    canvas.drawCircle(
      Offset(ballCenter.dx - 5, ballCenter.dy - 5),
      4.0,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _LivePreviewPainter oldDelegate) {
    return oldDelegate.ball.id != ball.id || oldDelegate.bar.id != bar.id;
  }
}
