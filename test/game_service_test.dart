import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balancing_maze/core/services/game_service.dart';
import 'package:balancing_maze/core/audio/audio_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameService gameService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    gameService = GameService(audioManager: AudioManager(isEnabled: false));
    await gameService.initialize();
  });

  group('GameService Economy & Progression Correctness', () {
    test('First clear gives first-clear bonus, replay prevents farming exploit', () async {
      final initialCoins = gameService.playerData.coins;

      // 1. First completion of Level 1 with 2 stars
      final result1 = await gameService.completeLevel(
        levelId: 1,
        score: 2000,
        stars: 2,
        coinsCollected: 25,
        completionTime: 45.0,
      );

      expect(result1['isFirstClear'], isTrue);
      // Expected coins: 25 collected + 100 first-clear bonus + 2*50 star bonus = 225
      expect(result1['coinsEarned'], 225);
      expect(gameService.playerData.coins, initialCoins + 225);
      expect(gameService.playerData.levelCompleted[1], isTrue);
      expect(gameService.playerData.getStarsForLevel(1), 2);
      expect(gameService.playerData.totalStars, 2);

      // 2. Replay with same stars (2 stars)
      final coinsAfterFirst = gameService.playerData.coins;
      final result2 = await gameService.completeLevel(
        levelId: 1,
        score: 2100,
        stars: 2,
        coinsCollected: 20,
        completionTime: 40.0,
      );

      expect(result2['isFirstClear'], isFalse);
      // Replay coins: round(20 * 0.4) = 8, no new star bonus, no first clear bonus
      expect(result2['coinsEarned'], 8);
      expect(gameService.playerData.coins, coinsAfterFirst + 8);

      // 3. Replay with improved stars (3 stars: delta = +1 star)
      final coinsAfterSecond = gameService.playerData.coins;
      final result3 = await gameService.completeLevel(
        levelId: 1,
        score: 3000,
        stars: 3,
        coinsCollected: 20,
        completionTime: 32.0,
      );

      expect(result3['isFirstClear'], isFalse);
      // Replay coins: round(20 * 0.4) = 8 + (1 new star * 50) = 58
      expect(result3['coinsEarned'], 58);
      expect(gameService.playerData.coins, coinsAfterSecond + 58);
      expect(gameService.playerData.getStarsForLevel(1), 3);
      expect(gameService.playerData.totalStars, 3);
    });

    test('Total play time accumulates across completed levels', () async {
      expect(gameService.playerData.totalPlayTimeSeconds, 0);

      await gameService.completeLevel(
        levelId: 1,
        score: 1500,
        stars: 1,
        coinsCollected: 15,
        completionTime: 42.4,
      );
      expect(gameService.playerData.totalPlayTimeSeconds, 42);

      await gameService.completeLevel(
        levelId: 2,
        score: 2500,
        stars: 2,
        coinsCollected: 20,
        completionTime: 58.6,
      );
      expect(gameService.playerData.totalPlayTimeSeconds, 42 + 59);
    });

    test('Achievements unlock and rewards cannot be double-claimed', () async {
      // Complete level 1
      await gameService.completeLevel(
        levelId: 1,
        score: 2000,
        stars: 2,
        coinsCollected: 25,
        completionTime: 35.0,
      );

      expect(gameService.playerData.achievementsCompleted['first_steps'], isTrue);

      final coinsBeforeClaim = gameService.playerData.coins;
      final reward = await gameService.claimAchievementReward('first_steps');
      expect(reward, 50);
      expect(gameService.playerData.coins, coinsBeforeClaim + 50);
      expect(gameService.playerData.achievementsClaimed['first_steps'], isTrue);

      // Attempt second claim
      final secondClaim = await gameService.claimAchievementReward('first_steps');
      expect(secondClaim, 0);
      expect(gameService.playerData.coins, coinsBeforeClaim + 50);
    });
  });

  group('Daily Reward Streak & Claim Rules', () {
    test('Daily reward claims consecutive days and resets on broken streak', () async {
      final day1 = DateTime(2026, 10, 1, 10, 0);
      expect(gameService.canClaimDailyReward(day1), isTrue);

      // Claim Day 1
      final reward1 = await gameService.claimDailyReward(day1);
      expect(reward1, 50); // Day 1 reward
      expect(gameService.playerData.dailyRewardDay, 2);

      // Cannot claim again on same calendar day
      final sameDayLater = DateTime(2026, 10, 1, 18, 0);
      expect(gameService.canClaimDailyReward(sameDayLater), isFalse);
      final doubleClaim = await gameService.claimDailyReward(sameDayLater);
      expect(doubleClaim, 0);

      // Claim Day 2 (consecutive day)
      final day2 = DateTime(2026, 10, 2, 9, 30);
      expect(gameService.canClaimDailyReward(day2), isTrue);
      final reward2 = await gameService.claimDailyReward(day2);
      expect(reward2, 75); // Day 2 reward
      expect(gameService.playerData.dailyRewardDay, 3);

      // Skip 2 days (missed streak) -> resets to Day 1
      final day5 = DateTime(2026, 10, 5, 11, 0);
      expect(gameService.canClaimDailyReward(day5), isTrue);
      final rewardReset = await gameService.claimDailyReward(day5);
      expect(rewardReset, 50); // Reset back to Day 1 reward!
      expect(gameService.playerData.dailyRewardDay, 2);
    });
  });

  group('Storage Resilience & Recovery', () {
    test('Corrupted save data backs up raw string and safely creates fresh profile', () async {
      SharedPreferences.setMockInitialValues({
        'player_data': '{invalid-json: corrupted content...',
      });

      final freshService = GameService();
      await freshService.initialize();

      expect(freshService.playerData.coins, 500); // Default starting coins
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('player_data_corrupt_backup'), '{invalid-json: corrupted content...');
    });
  });
}
