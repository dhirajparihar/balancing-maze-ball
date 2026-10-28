import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balancing_maze/core/services/game_service.dart';
import 'package:balancing_maze/core/audio/audio_manager.dart';
import 'package:balancing_maze/models/balance_runner_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameService gameService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    gameService = GameService(audioManager: AudioManager(isEnabled: false));
    await gameService.initialize();
  });

  group('Balance Runner Mechanics & Model Correctness', () {
    test('All 8 Ball Skins and 4 Bar Styles are properly defined', () {
      expect(BallSkinDef.allSkins.length, 8);
      expect(BarStyleDef.allStyles.length, 4);

      final classic = BallSkinDef.getById('classic_metallic');
      expect(classic.name, 'Classic Metallic');
      expect(classic.cost, 0);

      final cyanBar = BarStyleDef.getById('bar_cyan');
      expect(cyanBar.name, 'Cyan Glow');
      expect(cyanBar.cost, 0);
    });

    test('Progression & recordEndlessRun calculates score, coins, and records correctly', () async {
      // Record a run: 1,520 meters with score 6,080
      final result1 = await gameService.recordEndlessRun(
        distance: 1520,
        score: 6080,
      );

      expect(result1['isNewRecord'], true);
      expect(gameService.playerData.bestDistance, 1520);
      expect(gameService.playerData.bestScore, 6080);
      expect(result1['coinsEarned'], greaterThan(0));

      // Shorter run does not overwrite record
      final result2 = await gameService.recordEndlessRun(
        distance: 640,
        score: 1280,
      );

      expect(result2['isNewRecord'], false);
      expect(gameService.playerData.bestDistance, 1520);
      expect(gameService.playerData.bestScore, 6080);
    });

    test('Daily challenge seed and leaderboard return valid entries', () async {
      final dailyLeaderboard = gameService.getDailyChallengeLeaderboard();
      expect(dailyLeaderboard.isNotEmpty, true);
      expect(dailyLeaderboard.any((entry) => entry['isUser'] == true), true);

      final globalLeaderboard = gameService.getGlobalLeaderboard();
      expect(globalLeaderboard.length, greaterThanOrEqualTo(5));
      expect(globalLeaderboard.first['rank'], 1);
    });

    test('Equipping and unlocking skins adheres to player coins', () async {
      // Golden Glow costs 600
      final goldenSkin = BallSkinDef.getById('gold_glow');
      gameService.playerData.coins = 100;
      final failedUnlock = await gameService.unlockBallSkin(goldenSkin.id, goldenSkin.cost);
      expect(failedUnlock, false);

      // Now give sufficient coins
      gameService.playerData.coins = 1000;
      final successUnlock = await gameService.unlockBallSkin(goldenSkin.id, goldenSkin.cost);
      expect(successUnlock, true);
      expect(gameService.playerData.equippedMarbleSkin, 'gold_glow');
      expect(gameService.playerData.coins, 400);
    });
  });
}
