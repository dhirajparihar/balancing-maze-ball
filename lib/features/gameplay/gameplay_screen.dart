/// Gameplay screen — integrates Flame + Forge2D with Flutter overlays:
/// StartMenuOverlay, GameplayHudOverlay, ShopThemeSelectorSheet,
/// PauseModal, VictoryModal, FailedModal, and SettingsModal.
library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/game_providers.dart';
import '../../core/services/game_service.dart';
import '../../game/balancing_maze_game.dart';
import '../../game/systems/level_definitions.dart';
import '../../models/maze_theme_config.dart';
import '../level_map/level_map_screen.dart';
import 'overlays/failed_modal.dart';
import 'overlays/gameplay_hud_overlay.dart';
import 'overlays/pause_modal.dart';
import 'overlays/settings_modal.dart';
import 'overlays/shop_theme_selector_sheet.dart';
import 'overlays/start_menu_overlay.dart';
import 'overlays/victory_modal.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final GameService gameService;
  final int levelId;
  final bool startInMenu;

  const GameplayScreen({
    super.key,
    required this.gameService,
    this.levelId = 1,
    this.startInMenu = true,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> with WidgetsBindingObserver {
  late final BalancingMazeGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final initialTheme = MazeThemeConfig.getById(widget.gameService.playerData.selectedThemeId);
    final initialLevel = LevelDefinitions.getById(widget.levelId);

    _game = BalancingMazeGame(
      gameService: widget.gameService,
      initialLevel: initialLevel,
      initialTheme: initialTheme,
      startInMenu: widget.startInMenu,
      onGoalReached: (stars, score, elapsed, bounces) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(gamePlayStateProvider.notifier).recordGoalReached(
                stars: stars,
                finalScore: score,
                bestTrail: _game.personalBestGhostTrail,
              );
        });
      },
      onHoleFell: (hole, attempts) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(gamePlayStateProvider.notifier).recordHoleFall(
                attempts,
                _game.ghostTrail,
              );
        });
      },
      onWallBounce: (bounces) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(gamePlayStateProvider.notifier).recordWallBounce();
        });
      },
      onTimerTick: (remaining, elapsed) {
        // High-frequency physics timer ticks are rendered directly by GameplayHudOverlay.
        // Synchronous Riverpod mutations are omitted here to prevent build-cycle exceptions.
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      widget.gameService.audioManager.pauseMusic();
      if (_game.playState == GamePlayState.playing) {
        _game.pauseGame();
      }
    } else if (state == AppLifecycleState.resumed) {
      widget.gameService.audioManager.resumeMusic();
    }
  }

  void _handleMenuReturn() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _game.overlays.remove('PauseModal');
      _game.overlays.remove('VictoryModal');
      _game.overlays.remove('FailedModal');
      _game.overlays.remove('GameplayHud');
      _game.overlays.add('StartMenu');
      _game.playState = GamePlayState.menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Component-Based Theme Injection (Pillar 2):
    // Centralized MazeTheme provider via Riverpod updates colors, shaders, and particles
    // instantly without re-instantiating the physics body tree!
    ref.listen<MazeThemeConfig>(mazeThemeProvider, (previous, next) {
      if (previous != next) {
        _game.switchTheme(next);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<BalancingMazeGame>(
        game: _game,
        initialActiveOverlays: [
          widget.startInMenu ? 'StartMenu' : 'GameplayHud',
        ],
        overlayBuilderMap: {
          'StartMenu': (context, game) => StartMenuOverlay(
                game: game,
                onPlay: () {
                  game.overlays.remove('StartMenu');
                  game.overlays.add('GameplayHud');
                  game.elapsedTime = 0.0;
                  game.playState = GamePlayState.playing;
                  ref.read(gamePlayStateProvider.notifier).initLevel(game.currentLevel);
                },
                onPlayDailyChallenge: (level) {
                  game.overlays.remove('StartMenu');
                  game.overlays.add('GameplayHud');
                  game.loadLevelConfig(level);
                  game.elapsedTime = 0.0;
                  game.playState = GamePlayState.playing;
                  ref.read(gamePlayStateProvider.notifier).initLevel(level);
                },
                onOpenShop: () {
                  game.overlays.add('ShopTheme');
                },
                onOpenSettings: () {
                  game.overlays.add('SettingsModal');
                },
                onOpenLevelMap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, anim, _) => LevelMapScreen(gameService: widget.gameService),
                      transitionsBuilder: (context, anim, _, child) => FadeTransition(
                        opacity: anim,
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
          'GameplayHud': (context, game) => GameplayHudOverlay(
                game: game,
              ),
          'ShopTheme': (context, game) => ShopThemeSelectorSheet(
                game: game,
                onClose: () {
                  game.overlays.remove('ShopTheme');
                },
              ),
          'PauseModal': (context, game) => PauseModal(
                game: game,
                onResume: () {
                  game.resumeGame();
                },
                onRestart: () {
                  game.restartLevel();
                  ref.read(gamePlayStateProvider.notifier).initLevel(game.currentLevel);
                },
                onOpenSettings: () {
                  game.overlays.add('SettingsModal');
                },
                onQuit: _handleMenuReturn,
              ),
          'VictoryModal': (context, game) => VictoryModal(
                game: game,
                onNextLevel: () {
                  final nextId = game.currentLevel.id + 1;
                  game.overlays.remove('VictoryModal');
                  game.loadLevel(nextId);
                  ref.read(gamePlayStateProvider.notifier).initLevel(LevelDefinitions.getById(nextId));
                },
                onReplay: () {
                  game.restartLevel();
                  ref.read(gamePlayStateProvider.notifier).initLevel(game.currentLevel);
                },
                onMenu: _handleMenuReturn,
              ),
          'FailedModal': (context, game) => FailedModal(
                game: game,
                onRevive: () {
                  game.reviveMarble();
                },
                onTryAgain: () {
                  game.restartLevel();
                  ref.read(gamePlayStateProvider.notifier).initLevel(game.currentLevel);
                },
                onMenu: _handleMenuReturn,
              ),
          'SettingsModal': (context, game) => SettingsModal(
                game: game,
                onClose: () {
                  game.overlays.remove('SettingsModal');
                },
              ),
        },
      ),
    );
  }
}
