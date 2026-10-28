/// Central game service — manages player data, economy, progression, and achievements.
library;

import '../../models/player_data.dart';
import '../../models/shop_item.dart';
import '../../models/achievement.dart';
import '../storage/storage_service.dart';
import '../audio/audio_manager.dart';

class GameService {
  final StorageService _storage;
  final AudioManager audioManager;
  late PlayerData playerData;
  bool _initialized = false;

  GameService({StorageService? storage, AudioManager? audioManager})
      : _storage = storage ?? StorageService(),
        audioManager = audioManager ?? AudioManager();

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    await _storage.initialize();
    playerData = await _storage.loadPlayerData();
    await audioManager.initialize(playerData);
    _initialized = true;
  }

  Future<void> save() async {
    await _storage.savePlayerData(playerData);
  }

  // ---- Economy ----

  bool canAfford(int cost) => playerData.coins >= cost;

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0 || playerData.coins < amount) return false;
    playerData.coins -= amount;
    await save();
    return true;
  }

  Future<void> earnCoins(int amount) async {
    if (amount <= 0) return;
    playerData.coins += amount;
    await save();
  }

  // ---- Shop ----

  bool ownsItem(String itemId) => playerData.ownedItems.contains(itemId);

  Future<bool> purchaseItem(String itemId) async {
    if (ownsItem(itemId)) return false;
    final item = ShopInventory.getById(itemId);
    if (item == null) return false;
    if (!canAfford(item.price)) return false;

    playerData.coins -= item.price;
    playerData.ownedItems.add(itemId);

    // Auto-equip if it's a marble skin or trail
    if (item.category == ShopCategory.marbleSkin) {
      playerData.equippedMarbleSkin = itemId;
    } else if (item.category == ShopCategory.trail) {
      playerData.equippedTrail = itemId;
    }

    await save();
    audioManager.playSfx(SoundEffect.purchase);
    return true;
  }

  Future<void> equipItem(String itemId) async {
    if (!ownsItem(itemId)) return;
    final item = ShopInventory.getById(itemId);
    if (item == null) return;

    if (item.category == ShopCategory.marbleSkin) {
      playerData.equippedMarbleSkin = itemId;
    } else if (item.category == ShopCategory.trail) {
      playerData.equippedTrail = itemId;
    }
    await save();
  }

  // ---- Level Completion ----

  Future<Map<String, dynamic>> completeLevel({
    required int levelId,
    required int score,
    required int stars,
    required int coinsCollected,
    required double completionTime,
  }) async {
    // 1. GameService owns the first-clear determination from persistent state
    final bool isFirstClear = !(playerData.levelCompleted[levelId] ?? false);
    playerData.levelCompleted[levelId] = true;

    // Track cumulative play time
    playerData.totalPlayTimeSeconds += completionTime.round();

    int totalCoinsEarned = coinsCollected;
    bool newBest = false;

    // First completion gives full level & star bonuses
    if (isFirstClear) {
      totalCoinsEarned += 100; // First-clear level bonus
      totalCoinsEarned += stars * 50; // First-clear star bonus
    } else {
      // Replay gives balanced rewards: base coin share + bonus for newly unlocked stars
      final prevStars = playerData.levelStars[levelId] ?? 0;
      final newStarsEarned = stars > prevStars ? (stars - prevStars) : 0;
      totalCoinsEarned = (coinsCollected * 0.4).round() + (newStarsEarned * 50);
    }

    // Update best score
    final prevBest = playerData.levelBestScores[levelId] ?? 0;
    if (score > prevBest) {
      playerData.levelBestScores[levelId] = score;
      newBest = true;
    }

    // Update stars (keep best)
    final prevStars = playerData.levelStars[levelId] ?? 0;
    if (stars > prevStars) {
      playerData.levelStars[levelId] = stars;
      playerData.totalStars += (stars - prevStars);
    }

    // Update highest level
    if (levelId > playerData.highestLevelCompleted) {
      playerData.highestLevelCompleted = levelId;
    }

    // Update best overall score
    if (score > playerData.bestScore) {
      playerData.bestScore = score;
    }

    playerData.coins += totalCoinsEarned;
    await save();

    // Check achievements
    await _checkAchievements();

    return {
      'coinsEarned': totalCoinsEarned,
      'newBest': newBest,
      'starsAwarded': stars,
      'isFirstClear': isFirstClear,
    };
  }

  // ---- Daily Rewards ----

  bool canClaimDailyReward([DateTime? currentTime]) {
    if (playerData.lastDailyRewardClaim == null) return true;
    final now = currentTime ?? DateTime.now();
    final lastClaim = playerData.lastDailyRewardClaim!;
    final nextClaimDate =
        DateTime(lastClaim.year, lastClaim.month, lastClaim.day + 1);
    return now.isAfter(nextClaimDate) || now.isAtSameMomentAs(nextClaimDate);
  }

  Future<int> claimDailyReward([DateTime? currentTime]) async {
    if (!canClaimDailyReward(currentTime)) return 0;

    final now = currentTime ?? DateTime.now();
    if (playerData.lastDailyRewardClaim != null) {
      final last = playerData.lastDailyRewardClaim!;
      final diffDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;
      if (diffDays > 1) {
        // Missed consecutive day: reset streak to day 1
        playerData.dailyRewardDay = 1;
      }
    }

    final rewards = [50, 75, 100, 125, 150, 200, 300]; // 7-day cycle
    final dayIndex = (playerData.dailyRewardDay - 1).clamp(0, 6);
    final reward = rewards[dayIndex];

    playerData.coins += reward;
    playerData.lastDailyRewardClaim = now;
    playerData.dailyRewardDay = (playerData.dailyRewardDay % 7) + 1;
    await save();

    return reward;
  }

  // ---- Achievements ----

  Future<void> _checkAchievements() async {
    for (final achievement in Achievements.all) {
      if (playerData.achievementsCompleted[achievement.id] == true) continue;

      bool completed = false;
      switch (achievement.type) {
        case AchievementType.levelsCompleted:
          completed = playerData.levelCompleted.values
                  .where((v) => v)
                  .length >=
              achievement.targetValue;
          break;
        case AchievementType.starsEarned:
          completed = playerData.totalStars >= achievement.targetValue;
          break;
        case AchievementType.coinsCollected:
          completed = playerData.coins >= achievement.targetValue;
          break;
        case AchievementType.perfectLevels:
          completed = playerData.levelStars.values
                  .where((s) => s == 3)
                  .length >=
              achievement.targetValue;
          break;
        case AchievementType.worldsUnlocked:
          // Count distinct worlds/levels completed (up to 6)
          final worlds = playerData.levelCompleted.values.where((c) => c).length;
          completed = worlds >= achievement.targetValue;
          break;
        case AchievementType.skinsOwned:
          completed = playerData.ownedItems
                  .where((id) => id.startsWith('marble_'))
                  .length >=
              achievement.targetValue;
          break;
        case AchievementType.totalPlayTime:
          completed = playerData.totalPlayTimeSeconds >= achievement.targetValue;
          break;
      }

      if (completed) {
        playerData.achievementsCompleted[achievement.id] = true;
        await save();
      }
    }
  }

  Future<int> claimAchievementReward(String achievementId) async {
    if (playerData.achievementsCompleted[achievementId] != true) return 0;
    if (playerData.achievementsClaimed[achievementId] == true) return 0;

    final achievementIndex = Achievements.all.indexWhere((a) => a.id == achievementId);
    if (achievementIndex == -1) return 0;
    final achievement = Achievements.all[achievementIndex];

    playerData.achievementsClaimed[achievementId] = true;
    playerData.coins += achievement.rewardCoins;
    await save();
    audioManager.playSfx(SoundEffect.achievementUnlock);
    return achievement.rewardCoins;
  }

  // ---- Theme ----

  Future<bool> selectTheme(String themeId) async {
    playerData.selectedThemeId = themeId;
    await save();
    return true;
  }

  Future<bool> unlockTheme(String themeId, int cost) async {
    if (!canAfford(cost)) return false;
    playerData.coins -= cost;
    playerData.ownedItems.add('theme_$themeId');
    playerData.selectedThemeId = themeId;
    await save();
    audioManager.playSfx(SoundEffect.themeUnlock);
    return true;
  }

  bool isThemeUnlocked(String themeId) {
    if (themeId == 'neon_aqua') return true;
    return playerData.ownedItems.contains('theme_$themeId');
  }

  // ---- Settings ----

  Future<void> updateSettings({
    double? musicVolume,
    double? sfxVolume,
    bool? vibrationEnabled,
    String? graphicsQuality,
    double? controlSensitivity,
    bool? accelerometerEnabled,
    bool? leftHandedLayout,
    bool? reducedMotion,
  }) async {
    if (musicVolume != null) {
      playerData.musicVolume = musicVolume;
      audioManager.setMusicVolume(musicVolume);
    }
    if (sfxVolume != null) {
      playerData.sfxVolume = sfxVolume;
      audioManager.setSfxVolume(sfxVolume);
    }
    if (vibrationEnabled != null) {
      playerData.vibrationEnabled = vibrationEnabled;
    }
    if (graphicsQuality != null) {
      playerData.graphicsQuality = graphicsQuality;
    }
    if (controlSensitivity != null) {
      playerData.controlSensitivity = controlSensitivity;
    }
    if (accelerometerEnabled != null) {
      playerData.accelerometerEnabled = accelerometerEnabled;
    }
    if (leftHandedLayout != null) {
      playerData.leftHandedLayout = leftHandedLayout;
    }
    if (reducedMotion != null) playerData.reducedMotion = reducedMotion;
    await save();
  }

  // ---- Balance Runner Progression & Endless Runs ----

  Future<Map<String, dynamic>> recordEndlessRun({
    required int distance,
    required int score,
    bool isDailyChallenge = false,
  }) async {
    final bool isNewDistanceRecord = distance > playerData.bestDistance;
    final bool isNewScoreRecord = score > playerData.bestScore;

    if (isNewDistanceRecord) {
      playerData.bestDistance = distance;
    }
    if (isNewScoreRecord) {
      playerData.bestScore = score;
    }

    if (isDailyChallenge) {
      if (distance > playerData.dailyChallengeBestDistance) {
        playerData.dailyChallengeBestDistance = distance;
      }
      if (score > playerData.dailyChallengeBestScore) {
        playerData.dailyChallengeBestScore = score;
      }
      playerData.lastDailyChallengeDate = DateTime.now();
    }

    // Economy: Earn 1 coin for every 10 meters travelled, plus bonus for score
    final earnedCoins = (distance ~/ 10) + (score ~/ 200);
    playerData.coins += earnedCoins;

    await save();

    if (isNewDistanceRecord || isNewScoreRecord) {
      audioManager.playSfx(SoundEffect.victory);
    }

    return {
      'isNewRecord': isNewDistanceRecord,
      'bestDistance': playerData.bestDistance,
      'bestScore': playerData.bestScore,
      'coinsEarned': earnedCoins,
    };
  }

  Future<void> equipMarbleSkin(String skinId) async {
    playerData.equippedMarbleSkin = skinId;
    await save();
  }

  Future<void> equipBarSkin(String barSkinId) async {
    playerData.equippedBarSkin = barSkinId;
    await save();
  }

  Future<bool> unlockBallSkin(String skinId, int cost) async {
    final itemKey = 'marble_$skinId';
    if (playerData.ownedItems.contains(itemKey)) {
      playerData.equippedMarbleSkin = skinId;
      await save();
      return true;
    }
    if (!canAfford(cost)) return false;
    playerData.coins -= cost;
    playerData.ownedItems.add(itemKey);
    playerData.equippedMarbleSkin = skinId;
    await save();
    audioManager.playSfx(SoundEffect.purchase);
    return true;
  }

  Future<bool> unlockBarStyle(String barStyleId, int cost) async {
    final itemKey = 'bar_$barStyleId';
    if (playerData.ownedItems.contains(itemKey)) {
      playerData.equippedBarSkin = barStyleId;
      await save();
      return true;
    }
    if (!canAfford(cost)) return false;
    playerData.coins -= cost;
    playerData.ownedItems.add(itemKey);
    playerData.equippedBarSkin = barStyleId;
    await save();
    audioManager.playSfx(SoundEffect.purchase);
    return true;
  }

  bool isBallSkinUnlocked(String skinId) {
    if (skinId == 'classic_metallic' || skinId == 'neon_cyan') return true;
    return playerData.ownedItems.contains('marble_$skinId');
  }

  bool isBarStyleUnlocked(String barStyleId) {
    if (barStyleId == 'bar_cyan') return true;
    return playerData.ownedItems.contains('bar_$barStyleId');
  }

  List<Map<String, dynamic>> getGlobalLeaderboard() {
    final userDistance = playerData.bestDistance > 0 ? playerData.bestDistance : 2840;
    return [
      {'rank': 1, 'name': 'PlayerOne', 'distance': 12840, 'avatar': 'assets/images/avatar1.png'},
      {'rank': 2, 'name': 'SkyRunner', 'distance': 11920, 'avatar': 'assets/images/avatar2.png'},
      {'rank': 3, 'name': 'NeonBall', 'distance': 10450, 'avatar': 'assets/images/avatar3.png'},
      {'rank': 4, 'name': 'BalancePro', 'distance': 9880, 'avatar': 'assets/images/avatar4.png'},
      {'rank': 5, 'name': 'TiltMaster', 'distance': 8760, 'avatar': 'assets/images/avatar5.png'},
      {'rank': 6, 'name': 'VortexChaser', 'distance': 7430, 'avatar': 'assets/images/avatar6.png'},
      {'rank': 7, 'name': 'CyberApex', 'distance': 6920, 'avatar': 'assets/images/avatar7.png'},
      {'rank': 8, 'name': 'QuantumGlide', 'distance': 5840, 'avatar': 'assets/images/avatar8.png'},
      {'rank': 23, 'name': 'You', 'distance': userDistance, 'isUser': true},
    ];
  }

  List<Map<String, dynamic>> getFriendsLeaderboard() {
    final userDistance = playerData.bestDistance > 0 ? playerData.bestDistance : 2840;
    return [
      {'rank': 1, 'name': 'AlexPro', 'distance': 4220, 'avatar': 'assets/images/avatar1.png'},
      {'rank': 2, 'name': 'RunnerX', 'distance': 3980, 'avatar': 'assets/images/avatar2.png'},
      {'rank': 3, 'name': 'BallMaster', 'distance': 3760, 'avatar': 'assets/images/avatar3.png'},
      {'rank': 4, 'name': 'You', 'distance': userDistance, 'isUser': true},
      {'rank': 5, 'name': 'LunaTrek', 'distance': 2190, 'avatar': 'assets/images/avatar5.png'},
    ];
  }

  List<Map<String, dynamic>> getDailyChallengeLeaderboard() {
    final userDaily = playerData.dailyChallengeBestDistance > 0
        ? playerData.dailyChallengeBestDistance
        : (playerData.bestDistance > 0 ? (playerData.bestDistance * 0.8).round() : 1850);
    return [
      {'rank': 1, 'name': 'AlexPro', 'distance': 4220},
      {'rank': 2, 'name': 'RunnerX', 'distance': 3980},
      {'rank': 3, 'name': 'BallMaster', 'distance': 3760},
      {'rank': 4, 'name': 'GravityHero', 'distance': 3410},
      {'rank': 5, 'name': 'You', 'distance': userDaily, 'isUser': true},
    ];
  }

  Future<void> resetProgress() async {
    await _storage.resetAllData();
    playerData = PlayerData();
    await save();
  }
}
