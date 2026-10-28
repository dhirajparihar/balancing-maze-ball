/// Gameplay HUD Overlay — matches Reference Images 2 & 3:
/// Glassmorphic top bar with angled notch, Level, Timer, Score, 3 Stars, Pause,
/// dual mechanical thumb sliders (L and R) with real-time illuminated handles,
/// and concurrent multi-touch drag detection.
library;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../game/balancing_maze_game.dart';
import '../../../models/level_config.dart';
import '../../../models/maze_theme_config.dart';

class GameplayHudOverlay extends StatefulWidget {
  final BalancingMazeGame game;

  const GameplayHudOverlay({super.key, required this.game});

  @override
  State<GameplayHudOverlay> createState() => _GameplayHudOverlayState();
}

class _GameplayHudOverlayState extends State<GameplayHudOverlay> {
  // Concurrent Multi-Touch tracking pointers
  final Map<int, bool> _activePointersIsLeft = {};
  final Map<int, Offset> _activePointerPositions = {};
  Timer? _ticker;

  // Mechanical Ratchet Clicks tracking: ~8.0 logical px (~1.2mm) per tactile ratchet tooth
  double _leftAccumulatedTravel = 0.0;
  double _rightAccumulatedTravel = 0.0;
  static const double _ratchetThresholdPixels = 8.0;

  // Interactive Tutorial State
  bool _showTutorial = false;
  int _tutorialStep = 0; // 0: intro, 1: lift left, 2: observe roll, 3: counter-tilt brake, 4: cutouts/tape, 5: final goal

  @override
  void initState() {
    super.initState();
    _showTutorial = widget.game.currentLevel.id == 1 &&
        !widget.game.gameService.playerData.tutorialCompleted;

    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      if (_showTutorial) {
        if (_tutorialStep == 1 && widget.game.leftSliderNorm > 0.15) {
          setState(() => _tutorialStep = 2);
        } else if (_tutorialStep == 3 &&
            widget.game.rightSliderNorm > 0.12 &&
            (widget.game.leftSliderNorm - widget.game.rightSliderNorm).abs() < 0.15) {
          setState(() => _tutorialStep = 4);
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onThumbMove({required bool isLeft, required double dy}) {
    if (!widget.game.gameService.playerData.vibrationEnabled) return;

    if (isLeft) {
      _leftAccumulatedTravel += dy.abs();
      if (_leftAccumulatedTravel >= _ratchetThresholdPixels) {
        _leftAccumulatedTravel = 0.0;
        HapticFeedback.selectionClick();
        widget.game.gameService.audioManager.playRatchetClick();
      }
    } else {
      _rightAccumulatedTravel += dy.abs();
      if (_rightAccumulatedTravel >= _ratchetThresholdPixels) {
        _rightAccumulatedTravel = 0.0;
        HapticFeedback.selectionClick();
        widget.game.gameService.audioManager.playRatchetClick();
      }
    }
  }

  void _dismissTutorial() {
    setState(() => _showTutorial = false);
    widget.game.gameService.playerData.tutorialCompleted = true;
    widget.game.gameService.save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.game.currentTheme;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    final isLeftHanded = widget.game.gameService.playerData.leftHandedLayout;

    final hudTop = topPadding > 0 ? topPadding + 6.0 : 20.0;
    final sliderBottom = bottomPadding > 0 ? bottomPadding + 28.0 : 40.0;
    final hintBottom = bottomPadding > 0 ? bottomPadding + 8.0 : 16.0;

    return Stack(
      children: [
        // 1. Carriage Control Surface (Starts below Top HUD bar to prevent accidental touch-through to controls)
        Positioned(
          top: hudTop + 62.0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              final touchIsLeftScreen = event.position.dx < mediaQuery.size.width / 2.0;
              // In left-handed layout, the R slider is rendered on the left, so left-screen touch controls R
              final controlsLeftCarriage = isLeftHanded ? !touchIsLeftScreen : touchIsLeftScreen;
              _activePointersIsLeft[event.pointer] = controlsLeftCarriage;
              _activePointerPositions[event.pointer] = event.position;
              if (widget.game.gameService.playerData.vibrationEnabled) {
                HapticFeedback.selectionClick();
              }
              widget.game.gameService.audioManager.playRatchetClick();
              setState(() {});
            },
            onPointerMove: (event) {
              final isLeft = _activePointersIsLeft[event.pointer];
              _activePointerPositions[event.pointer] = event.position;
              if (isLeft == null) return;

              // Drag up lifts the carriage (negative delta Y in screen pixels = upward lifting)
              final deltaNorm = -event.delta.dy / 300.0;
              _onThumbMove(isLeft: isLeft, dy: event.delta.dy);

              if (isLeft) {
                widget.game.adjustLeftSliderDelta(deltaNorm);
              } else {
                widget.game.adjustRightSliderDelta(deltaNorm);
              }
              setState(() {});
            },
            onPointerUp: (event) {
              _activePointersIsLeft.remove(event.pointer);
              _activePointerPositions.remove(event.pointer);
              setState(() {});
            },
            onPointerCancel: (event) {
              _activePointersIsLeft.remove(event.pointer);
              _activePointerPositions.remove(event.pointer);
              setState(() {});
            },
          ),
        ),

        // 2. Top Glassmorphic HUD Bar (Isolated RepaintBoundary)
        Positioned(
          top: hudTop,
          left: 14,
          right: 14,
          child: RepaintBoundary(
            child: _buildTopStatusBar(theme),
          ),
        ),

        // 3. Left Mechanical Slider (L) (Isolated RepaintBoundary)
        Positioned(
          left: isLeftHanded ? null : 14,
          right: isLeftHanded ? 14 : null,
          bottom: sliderBottom,
          child: RepaintBoundary(
            child: _buildVerticalSliderTrack(
              label: 'L',
              normalizedValue: widget.game.leftSliderNorm,
              isHighlighted: _showTutorial && _tutorialStep == 1,
              onChanged: (val) {
                widget.game.setLeftSliderNormalized(val);
                setState(() {});
              },
              theme: theme,
            ),
          ),
        ),

        // 4. Right Mechanical Slider (R) (Isolated RepaintBoundary)
        Positioned(
          left: isLeftHanded ? 14 : null,
          right: isLeftHanded ? null : 14,
          bottom: sliderBottom,
          child: RepaintBoundary(
            child: _buildVerticalSliderTrack(
              label: 'R',
              normalizedValue: widget.game.rightSliderNorm,
              isHighlighted: _showTutorial && _tutorialStep == 3,
              onChanged: (val) {
                widget.game.setRightSliderNormalized(val);
                setState(() {});
              },
              theme: theme,
            ),
          ),
        ),

        // 5. Interactive Tutorial Coach Card (Isolated RepaintBoundary)
        if (_showTutorial)
          Positioned(
            top: hudTop + 76,
            left: 20,
            right: 20,
            child: RepaintBoundary(
              child: _buildTutorialCard(theme),
            ),
          ),

        // 6. Active Thumb Halos (Subtle glowing rings following active touch points)
        for (final entry in _activePointerPositions.entries)
          Positioned(
            left: entry.value.dx - 28,
            top: entry.value.dy - 28,
            child: IgnorePointer(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.rimGlowColor.withValues(alpha: 0.65),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.rimGlowColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 7. Dynamic Bottom Cue ("TAP & DRAG TO BALANCE" or "⚠️ TILT OPPOSITE TO BRAKE")
        if (!_showTutorial)
          Positioned(
            bottom: hintBottom,
            left: 30,
            right: 30,
            child: Center(
              child: Text(
                widget.game.marbleSpeed > 16.0
                    ? '⚠️ HIGH SPEED — TILT OPPOSITE TO BRAKE!'
                    : 'TAP & DRAG TO BALANCE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.game.marbleSpeed > 16.0
                      ? const Color(0xFFFFB74D)
                      : theme.hudTextColor.withValues(alpha: 0.75),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: (widget.game.marbleSpeed > 16.0
                              ? const Color(0xFFFF9800)
                              : theme.rimGlowColor)
                          .withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Top Glassmorphic Status Bar with angled bottom notch
  Widget _buildTopStatusBar(MazeThemeConfig theme) {
    final scoreStr = NumberFormat('#,###').format(widget.game.score);
    final levelNumStr = widget.game.currentLevel.id.toString().padLeft(2, '0');
    final secondsLeft = widget.game.remainingTime.ceil();
    final m = secondsLeft ~/ 60;
    final s = secondsLeft % 60;
    final timerStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.hudBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.rimGlowColor.withValues(alpha: 0.2),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.hudBgColor.withValues(alpha: 0.88),
            theme.hudBgColor.withValues(alpha: 0.70),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEVEL 04 & Attempt counter
              // LEVEL 04 & Attempt counter & Modifier
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.game.currentLevel.mode == LevelMode.dailyChallenge
                              ? 'DAILY'
                              : 'LEVEL',
                          style: TextStyle(
                            color: theme.hudTextColor.withValues(alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (widget.game.attempts > 1) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: theme.rimGlowColor.withValues(alpha: 0.25),
                              border: Border.all(color: theme.rimGlowColor.withValues(alpha: 0.6), width: 0.8),
                            ),
                            child: Text(
                              'RUN ${widget.game.attempts}',
                              style: TextStyle(
                                color: theme.hudTextColor,
                                fontSize: 8.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      widget.game.currentLevel.mode == LevelMode.dailyChallenge
                          ? 'CHALLENGE'
                          : levelNumStr,
                      style: TextStyle(
                        color: theme.hudTextColor,
                        fontSize: widget.game.currentLevel.mode == LevelMode.dailyChallenge ? 15 : 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: theme.rimGlowColor.withValues(alpha: 0.9),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Active Modifier or Clean Instrument Tag
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.game.currentLevel.modifier != DailyModifier.none) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: widget.game.currentLevel.modifier.badgeColor.withValues(alpha: 0.25),
                              border: Border.all(
                                color: widget.game.currentLevel.modifier.badgeColor,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              widget.game.currentLevel.modifier.displayName,
                              style: TextStyle(
                                color: widget.game.currentLevel.modifier.badgeColor,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        // Clean Run / Bounces
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: widget.game.wallBounces == 0
                                ? const Color(0xFF00E676).withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                          ),
                          child: Text(
                            widget.game.wallBounces == 0 ? 'CLEAN 🟢' : 'BOUNCES: ${widget.game.wallBounces}',
                            style: TextStyle(
                              color: widget.game.wallBounces == 0 ? const Color(0xFF69F0AE) : const Color(0xFFFF8A80),
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Timer (Clock icon + 01:24)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: secondsLeft <= 15 ? theme.hudTimerWarningColor : theme.hudTextColor,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timerStr,
                    style: TextStyle(
                      color: secondsLeft <= 15 ? theme.hudTimerWarningColor : theme.hudTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: secondsLeft <= 15
                              ? theme.hudTimerWarningColor.withValues(alpha: 0.9)
                              : theme.rimGlowColor.withValues(alpha: 0.9),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // SCORE: 1,420 + 3 Stars + PB Ghost indicator
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SCORE: $scoreStr',
                    style: TextStyle(
                      color: theme.hudTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final isLit = i < widget.game.stars;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(
                          isLit ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isLit ? theme.hudAccentColor : theme.hudBorderColor,
                          size: 16,
                        ),
                      );
                    }),
                  ),
                  if (widget.game.personalBestGhostTrail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '★ PB GHOST ON',
                      style: TextStyle(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                        fontSize: 8.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ],
              ),

              // Pause Button (||)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.game.pauseGame();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.hudBorderColor.withValues(alpha: 0.25),
                    border: Border.all(
                      color: theme.hudBorderColor,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.pause_rounded,
                      color: theme.hudTextColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mechanical Vertical Slider Track (L & R)
  Widget _buildVerticalSliderTrack({
    required String label,
    required double normalizedValue,
    required ValueChanged<double> onChanged,
    required MazeThemeConfig theme,
    bool isHighlighted = false,
  }) {
    const width = 54.0;
    const height = 260.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width / 2),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFFFD54F) : theme.sliderContainerBorder,
          width: isHighlighted ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? const Color(0xFFFFD54F).withValues(alpha: 0.6)
                : theme.sliderThumbGlow.withValues(alpha: 0.25),
            blurRadius: isHighlighted ? 22 : 16,
            spreadRadius: isHighlighted ? 2 : 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.sliderContainerBg.withValues(alpha: 0.35),
            theme.sliderContainerBg.withValues(alpha: 0.15),
            theme.sliderContainerBg.withValues(alpha: 0.25),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // "L" or "R" header
              Text(
                label,
                style: TextStyle(
                  color: isHighlighted ? const Color(0xFFFFD54F) : theme.sliderLabelColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: isHighlighted
                          ? const Color(0xFFFFD54F).withValues(alpha: 0.9)
                          : theme.sliderThumbGlow.withValues(alpha: 0.9),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Interactive Slider Track
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final h = constraints.maxHeight;
                    // Knob position (normalized: 0 = bottom, 1 = top)
                    final knobY = (1.0 - normalizedValue.clamp(0.0, 1.0)) * (h - 32);

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (details) {
                        _onThumbMove(isLeft: label == 'L', dy: details.delta.dy);
                        final localY = details.localPosition.dy.clamp(0.0, h);
                        final norm = (1.0 - (localY / h)).clamp(0.0, 1.0);
                        onChanged(norm);
                      },
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Background slot track
                          Positioned(
                            top: 14,
                            bottom: 14,
                            child: Container(
                              width: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.5),
                                color: theme.sliderStemColor,
                                border: Border.all(
                                  color: theme.sliderLabelColor.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                            ),
                          ),

                          // Neutral resting baseline marker (level bar at start)
                          Positioned(
                            bottom: 16,
                            child: Container(
                              width: 14,
                              height: 2,
                              decoration: BoxDecoration(
                                color: isHighlighted
                                    ? const Color(0xFFFFD54F)
                                    : theme.sliderLabelColor.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),

                          // Active filled stem
                          Positioned(
                            top: knobY + 16,
                            bottom: 14,
                            child: Container(
                              width: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: isHighlighted ? const Color(0xFFFFD54F) : theme.sliderActiveStemColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: isHighlighted
                                        ? const Color(0xFFFFD54F).withValues(alpha: 0.8)
                                        : theme.sliderThumbGlow.withValues(alpha: 0.7),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Illuminated Glowing Thumb Knob
                          Positioned(
                            top: knobY,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    isHighlighted ? Colors.white : theme.sliderThumbInner,
                                    isHighlighted ? const Color(0xFFFFD54F) : theme.sliderThumbOuter,
                                    Color.lerp(theme.sliderThumbOuter, Colors.black, 0.4)!,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isHighlighted
                                        ? const Color(0xFFFFD54F).withValues(alpha: 0.9)
                                        : theme.sliderThumbGlow.withValues(alpha: 0.9),
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Interactive Tutorial Coaching Card
  Widget _buildTutorialCard(MazeThemeConfig theme) {
    String title;
    String description;
    String? actionLabel;
    VoidCallback? onAction;
    IconData icon;

    switch (_tutorialStep) {
      case 0:
        title = 'WELCOME TO BALANCING MAZE';
        description = 'Control the board by lifting the Left and Right sliders independently to steer the marble.';
        actionLabel = 'START TUTORIAL ▶';
        onAction = () => setState(() => _tutorialStep = 1);
        icon = Icons.sports_esports_rounded;
        break;
      case 1:
        title = 'STEP 1: LIFT LEFT SIDE (L)';
        description = 'Drag the highlighted LEFT slider UP to lift the left carriage. Watch the board tilt!';
        actionLabel = null; // Auto-advances when user drags
        icon = Icons.arrow_upward_rounded;
        break;
      case 2:
        title = 'STEP 2: WATCH IT ROLL!';
        description = 'Because the left side is higher, the slope makes the marble roll right across the bar.';
        actionLabel = 'LEARN TO BRAKE ▶';
        onAction = () => setState(() => _tutorialStep = 3);
        icon = Icons.trending_down_rounded;
        break;
      case 3:
        title = 'STEP 3: COUNTER-TILT TO BRAKE';
        description = 'Now lift the RIGHT slider (R) to level the bar and brake/stop the marble!';
        actionLabel = null; // Auto-advances when leveled
        icon = Icons.pause_circle_outline_rounded;
        break;
      case 4:
        title = 'STEP 4: AVOID CUTOUTS & FEEL RIMS';
        description = 'Beveled holes pull the ball in. You will feel warning vibrations. Taped holes protect you on your first pass!';
        actionLabel = 'NEXT: FINAL GOAL ▶';
        onAction = () => setState(() => _tutorialStep = 5);
        icon = Icons.warning_amber_rounded;
        break;
      case 5:
      default:
        title = 'STEP 5: REACH THE GOAL CUP';
        description = 'Balance and lift both sliders smoothly to guide the marble into the illuminated top cup!';
        actionLabel = "LET'S PLAY! 🏁";
        onAction = _dismissTutorial;
        icon = Icons.emoji_events_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0F1E33).withValues(alpha: 0.94),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Step and Skip Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFFFD54F), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _dismissTutorial,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: const Text(
                    'SKIP',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description text
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFECEFF1),
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Action button if not waiting for dynamic gesture
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                if (widget.game.gameService.playerData.vibrationEnabled) {
                  HapticFeedback.lightImpact();
                }
                onAction?.call();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Color(0xFF061822),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _tutorialStep == 1 ? 'Waiting for left slider drag...' : 'Waiting for bar leveling...',
                  style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
