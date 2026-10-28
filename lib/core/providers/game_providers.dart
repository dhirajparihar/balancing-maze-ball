/// Central Riverpod Providers — Scalability Pillars 2 & 3.
/// Decouples Flame/Forge2D physics from Flutter UI and enables reactive theme injection.
library;

import 'package:flame/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/level_config.dart';
import '../../models/maze_theme_config.dart';
import '../services/game_service.dart';
import '../../game/systems/level_definitions.dart';

/// 1. Central GameService Provider
final gameServiceProvider = Provider<GameService>((ref) {
  throw UnimplementedError('Override gameServiceProvider in ProviderScope');
});

/// 2. Reactive Theme Provider (Component-Based Theme Injection — Pillar 2)
final mazeThemeProvider = StateNotifierProvider<MazeThemeNotifier, MazeThemeConfig>((ref) {
  final service = ref.watch(gameServiceProvider);
  final initialTheme = MazeThemeConfig.getById(service.playerData.selectedThemeId);
  return MazeThemeNotifier(initialTheme, service);
});

class MazeThemeNotifier extends StateNotifier<MazeThemeConfig> {
  final GameService gameService;

  MazeThemeNotifier(super.state, this.gameService);

  void selectTheme(MazeThemeConfig newTheme) {
    state = newTheme;
    gameService.selectTheme(newTheme.id);
  }
}

/// 3. Daily Challenge Provider (Dynamic Modifiers — Part 1)
final dailyChallengeProvider = Provider<BoardLevel>((ref) {
  return DailyChallengeService.getTodaysChallenge();
});

/// 4. Decoupled UI & Gameplay Snapshot State Model — Pillar 3
class GamePlaySnapshot {
  final int levelId;
  final String levelTitle;
  final String modeName;
  final DailyModifier modifier;
  final double coinMultiplier;
  final int score;
  final int stars;
  final int attempts;
  final int wallBounces;
  final bool isCleanRun;
  final double elapsedTime;
  final double remainingTime;
  final bool isPlaying;
  final bool isGoalReached;
  final bool isFailed;
  final List<Vector2>? personalBestGhostTrail;
  final List<Vector2>? lastFailGhostTrail;

  const GamePlaySnapshot({
    required this.levelId,
    required this.levelTitle,
    required this.modeName,
    this.modifier = DailyModifier.none,
    this.coinMultiplier = 1.0,
    this.score = 0,
    this.stars = 0,
    this.attempts = 1,
    this.wallBounces = 0,
    this.isCleanRun = true,
    this.elapsedTime = 0.0,
    this.remainingTime = 120.0,
    this.isPlaying = false,
    this.isGoalReached = false,
    this.isFailed = false,
    this.personalBestGhostTrail,
    this.lastFailGhostTrail,
  });

  GamePlaySnapshot copyWith({
    int? levelId,
    String? levelTitle,
    String? modeName,
    DailyModifier? modifier,
    double? coinMultiplier,
    int? score,
    int? stars,
    int? attempts,
    int? wallBounces,
    bool? isCleanRun,
    double? elapsedTime,
    double? remainingTime,
    bool? isPlaying,
    bool? isGoalReached,
    bool? isFailed,
    List<Vector2>? personalBestGhostTrail,
    List<Vector2>? lastFailGhostTrail,
  }) {
    return GamePlaySnapshot(
      levelId: levelId ?? this.levelId,
      levelTitle: levelTitle ?? this.levelTitle,
      modeName: modeName ?? this.modeName,
      modifier: modifier ?? this.modifier,
      coinMultiplier: coinMultiplier ?? this.coinMultiplier,
      score: score ?? this.score,
      stars: stars ?? this.stars,
      attempts: attempts ?? this.attempts,
      wallBounces: wallBounces ?? this.wallBounces,
      isCleanRun: isCleanRun ?? this.isCleanRun,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      remainingTime: remainingTime ?? this.remainingTime,
      isPlaying: isPlaying ?? this.isPlaying,
      isGoalReached: isGoalReached ?? this.isGoalReached,
      isFailed: isFailed ?? this.isFailed,
      personalBestGhostTrail: personalBestGhostTrail ?? this.personalBestGhostTrail,
      lastFailGhostTrail: lastFailGhostTrail ?? this.lastFailGhostTrail,
    );
  }
}

/// 5. Gameplay State Notifier (Decoupled Physics & UI State)
final gamePlayStateProvider = StateNotifierProvider<GamePlayStateNotifier, GamePlaySnapshot>((ref) {
  return GamePlayStateNotifier();
});

class GamePlayStateNotifier extends StateNotifier<GamePlaySnapshot> {
  GamePlayStateNotifier()
      : super(const GamePlaySnapshot(
          levelId: 1,
          levelTitle: 'LEVEL 01',
          modeName: 'TAPED TRAINING',
        ));

  void initLevel(BoardLevel level) {
    state = GamePlaySnapshot(
      levelId: level.id,
      levelTitle: level.title,
      modeName: level.modeName,
      modifier: level.modifier,
      coinMultiplier: level.coinMultiplier,
      score: 0,
      stars: 0,
      attempts: 1,
      wallBounces: 0,
      isCleanRun: true,
      elapsedTime: 0.0,
      remainingTime: level.timerSeconds.toDouble(),
      isPlaying: true,
      isGoalReached: false,
      isFailed: false,
    );
  }

  void updateTimer(double remaining, double elapsed) {
    state = state.copyWith(remainingTime: remaining, elapsedTime: elapsed);
  }

  void recordWallBounce() {
    final nextBounces = state.wallBounces + 1;
    state = state.copyWith(
      wallBounces: nextBounces,
      isCleanRun: false,
    );
  }

  void recordHoleFall(int attempts, List<Vector2>? failTrail) {
    state = state.copyWith(
      attempts: attempts,
      lastFailGhostTrail: failTrail,
    );
  }

  void recordGoalReached({
    required int stars,
    required int finalScore,
    required List<Vector2>? bestTrail,
  }) {
    state = state.copyWith(
      stars: stars,
      score: finalScore,
      isGoalReached: true,
      isPlaying: false,
      personalBestGhostTrail: bestTrail,
    );
  }

  void setScore(int newScore) {
    state = state.copyWith(score: newScore);
  }
}
