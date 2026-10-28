/// Achievement definitions.
library;

class Achievement {
  final String id;
  final String name;
  final String description;
  final int rewardCoins;
  final int targetValue;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.rewardCoins,
    required this.targetValue,
    required this.type,
  });
}

enum AchievementType {
  levelsCompleted,
  starsEarned,
  coinsCollected,
  perfectLevels, // 3 stars
  worldsUnlocked,
  skinsOwned,
  totalPlayTime,
}

class Achievements {
  Achievements._();

  static const List<Achievement> all = [
    Achievement(
      id: 'first_steps',
      name: 'First Steps',
      description: 'Complete your first level.',
      rewardCoins: 50,
      targetValue: 1,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'campaign_champion',
      name: 'Campaign Champion',
      description: 'Complete all 6 Campaign levels.',
      rewardCoins: 300,
      targetValue: 6,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'rising_star',
      name: 'Rising Star',
      description: 'Earn 6 stars.',
      rewardCoins: 100,
      targetValue: 6,
      type: AchievementType.starsEarned,
    ),
    Achievement(
      id: 'star_master',
      name: 'Star Master',
      description: 'Earn all 18 stars across the campaign.',
      rewardCoins: 500,
      targetValue: 18,
      type: AchievementType.starsEarned,
    ),
    Achievement(
      id: 'perfectionist',
      name: 'Perfectionist',
      description: 'Achieve 3 stars on at least 3 levels.',
      rewardCoins: 250,
      targetValue: 3,
      type: AchievementType.perfectLevels,
    ),
    Achievement(
      id: 'dedicated_balancer',
      name: 'Dedicated Balancer',
      description: 'Play for 5 minutes total.',
      rewardCoins: 150,
      targetValue: 300,
      type: AchievementType.totalPlayTime,
    ),
    Achievement(
      id: 'coin_hoarder',
      name: 'Coin Hoarder',
      description: 'Accumulate 1,000 coins total.',
      rewardCoins: 200,
      targetValue: 1000,
      type: AchievementType.coinsCollected,
    ),
    Achievement(
      id: 'fashionista',
      name: 'Fashionista',
      description: 'Own 3 marble skins.',
      rewardCoins: 250,
      targetValue: 3,
      type: AchievementType.skinsOwned,
    ),
  ];
}
