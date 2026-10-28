/// Gameplay Screen — integrates BalanceRunnerGame with GameWidget & Flutter Overlays:
/// Top Glass HUD (Distance, Time, Multiplier, Pause),
/// PauseModal, and FailedModal (Game Over).
library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/services/game_service.dart';
import '../../game/balance_runner_game.dart';
import 'overlays/failed_modal.dart';
import 'overlays/gameplay_hud_overlay.dart';
import 'overlays/pause_modal.dart';

class GameplayScreen extends StatefulWidget {
  final GameService gameService;
  final int? seed;
  final bool isDailyChallenge;
  final int? levelId;
  final bool startInMenu;

  const GameplayScreen({
    super.key,
    required this.gameService,
    this.seed,
    this.isDailyChallenge = false,
    this.levelId,
    this.startInMenu = false,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with WidgetsBindingObserver {
  late final BalanceRunnerGame _game;
  final ValueNotifier<BalanceRunnerHudData> _hudNotifier = ValueNotifier(const BalanceRunnerHudData());

  bool _isNewRecord = false;
  int _bestDistance = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bestDistance = widget.isDailyChallenge
        ? widget.gameService.playerData.dailyChallengeBestDistance
        : widget.gameService.playerData.bestDistance;

    _game = BalanceRunnerGame(
      gameService: widget.gameService,
      seed: widget.seed,
      isDailyChallenge: widget.isDailyChallenge,
    );

    _game.onHudUpdate = (dist, sc, mult, t) {
      _hudNotifier.value = BalanceRunnerHudData(
        distance: dist,
        score: sc,
        multiplier: mult,
        time: t,
      );
    };

    _game.onGameOver = (dist, sc) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final result = await widget.gameService.recordEndlessRun(
          distance: dist,
          score: sc,
          isDailyChallenge: widget.isDailyChallenge,
        );

        if (!mounted) return;
        setState(() {
          _isNewRecord = result['isNewRecord'] as bool? ?? false;
          _bestDistance = result['bestDistance'] as int? ?? dist;
        });

        _game.overlays.add('GameOverModal');
      });
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hudNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_game.state == RunnerState.playing) {
        _onPause();
      }
    }
  }

  void _onPause() {
    _game.pause();
    _game.overlays.add('PauseModal');
  }

  void _onResume() {
    _game.overlays.remove('PauseModal');
    _game.resume();
  }

  void _onRestart() {
    _game.overlays.remove('PauseModal');
    _game.overlays.remove('GameOverModal');
    _game.restart();
    _hudNotifier.value = const BalanceRunnerHudData();
    setState(() {
      _isNewRecord = false;
    });
  }

  void _onHome() {
    _game.overlays.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061019),
      body: GameWidget<BalanceRunnerGame>(
        game: _game,
        initialActiveOverlays: const ['GameplayHud'],
        overlayBuilderMap: {
          'GameplayHud': (context, game) => GameplayHudOverlay(
                game: game,
                hudNotifier: _hudNotifier,
                onPause: _onPause,
              ),
          'PauseModal': (context, game) => PauseModal(
                distance: _hudNotifier.value.distance,
                time: _hudNotifier.value.time,
                multiplier: _hudNotifier.value.multiplier,
                onResume: _onResume,
                onRestart: _onRestart,
                onMainMenu: _onHome,
              ),
          'GameOverModal': (context, game) => FailedModal(
                distance: _hudNotifier.value.distance,
                score: _hudNotifier.value.score,
                bestDistance: _bestDistance,
                isNewRecord: _isNewRecord,
                onRetry: _onRestart,
                onHome: _onHome,
              ),
        },
      ),
    );
  }
}
