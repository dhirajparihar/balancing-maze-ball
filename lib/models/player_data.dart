/// Player data model — persistent progression state.
library;

class PlayerData {
  int coins;
  int bestScore;
  int bestDistance; // in meters
  int totalStars;
  int highestLevelCompleted;
  Map<int, int> levelStars; // levelId -> stars (0-3)
  Map<int, int> levelBestScores; // levelId -> best score
  Map<int, bool> levelCompleted; // levelId -> completed
  Set<String> ownedItems; // item IDs
  String equippedMarbleSkin;
  String equippedBarSkin;
  String equippedTrail;
  String selectedThemeId;
  Map<String, bool> achievementsCompleted;
  Map<String, bool> achievementsClaimed;
  int dailyRewardDay; // 1-7 cycle
  DateTime? lastDailyRewardClaim;
  int dailyChallengeBestDistance;
  int dailyChallengeBestScore;
  DateTime? lastDailyChallengeDate;
  bool tutorialCompleted;
  int totalPlayTimeSeconds;
  double musicVolume;
  double sfxVolume;
  bool vibrationEnabled;
  String graphicsQuality; // low, medium, high
  double controlSensitivity;
  bool accelerometerEnabled;
  bool leftHandedLayout;
  bool reducedMotion;
  int dataVersion;

  PlayerData({
    this.coins = 500,
    this.bestScore = 0,
    this.bestDistance = 0,
    this.totalStars = 0,
    this.highestLevelCompleted = 0,
    Map<int, int>? levelStars,
    Map<int, int>? levelBestScores,
    Map<int, bool>? levelCompleted,
    Set<String>? ownedItems,
    this.equippedMarbleSkin = 'classic_metallic',
    this.equippedBarSkin = 'bar_cyan',
    this.equippedTrail = 'default',
    this.selectedThemeId = 'neon_aqua',
    Map<String, bool>? achievementsCompleted,
    Map<String, bool>? achievementsClaimed,
    this.dailyRewardDay = 1,
    this.lastDailyRewardClaim,
    this.dailyChallengeBestDistance = 0,
    this.dailyChallengeBestScore = 0,
    this.lastDailyChallengeDate,
    this.tutorialCompleted = false,
    this.totalPlayTimeSeconds = 0,
    this.musicVolume = 0.7,
    this.sfxVolume = 1.0,
    this.vibrationEnabled = true,
    this.graphicsQuality = 'high',
    this.controlSensitivity = 1.0,
    this.accelerometerEnabled = false,
    this.leftHandedLayout = false,
    this.reducedMotion = false,
    this.dataVersion = 2,
  })  : levelStars = levelStars ?? {},
        levelBestScores = levelBestScores ?? {},
        levelCompleted = levelCompleted ?? {},
        ownedItems = ownedItems ?? {
          'marble_classic_metallic',
          'marble_neon_cyan',
          'bar_cyan',
          'trail_default',
        },
        achievementsCompleted = achievementsCompleted ?? {},
        achievementsClaimed = achievementsClaimed ?? {};

  bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    return levelCompleted[levelId - 1] == true;
  }

  int getStarsForLevel(int levelId) => levelStars[levelId] ?? 0;

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'bestScore': bestScore,
        'bestDistance': bestDistance,
        'totalStars': totalStars,
        'highestLevelCompleted': highestLevelCompleted,
        'levelStars':
            levelStars.map((k, v) => MapEntry(k.toString(), v)),
        'levelBestScores':
            levelBestScores.map((k, v) => MapEntry(k.toString(), v)),
        'levelCompleted':
            levelCompleted.map((k, v) => MapEntry(k.toString(), v)),
        'ownedItems': ownedItems.toList(),
        'equippedMarbleSkin': equippedMarbleSkin,
        'equippedBarSkin': equippedBarSkin,
        'equippedTrail': equippedTrail,
        'selectedThemeId': selectedThemeId,
        'achievementsCompleted': achievementsCompleted,
        'achievementsClaimed': achievementsClaimed,
        'dailyRewardDay': dailyRewardDay,
        'lastDailyRewardClaim': lastDailyRewardClaim?.toIso8601String(),
        'dailyChallengeBestDistance': dailyChallengeBestDistance,
        'dailyChallengeBestScore': dailyChallengeBestScore,
        'lastDailyChallengeDate': lastDailyChallengeDate?.toIso8601String(),
        'tutorialCompleted': tutorialCompleted,
        'totalPlayTimeSeconds': totalPlayTimeSeconds,
        'musicVolume': musicVolume,
        'sfxVolume': sfxVolume,
        'vibrationEnabled': vibrationEnabled,
        'graphicsQuality': graphicsQuality,
        'controlSensitivity': controlSensitivity,
        'accelerometerEnabled': accelerometerEnabled,
        'leftHandedLayout': leftHandedLayout,
        'reducedMotion': reducedMotion,
        'dataVersion': dataVersion,
      };

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      coins: json['coins'] as int? ?? 500,
      bestScore: json['bestScore'] as int? ?? 0,
      bestDistance: json['bestDistance'] as int? ?? 0,
      totalStars: json['totalStars'] as int? ?? 0,
      highestLevelCompleted: json['highestLevelCompleted'] as int? ?? 0,
      levelStars: (json['levelStars'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
          {},
      levelBestScores: (json['levelBestScores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
          {},
      levelCompleted: (json['levelCompleted'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as bool)) ??
          {},
      ownedItems: (json['ownedItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {
            'marble_classic_metallic',
            'marble_neon_cyan',
            'bar_cyan',
            'trail_default',
          },
      equippedMarbleSkin:
          json['equippedMarbleSkin'] as String? ?? 'classic_metallic',
      equippedBarSkin:
          json['equippedBarSkin'] as String? ?? 'bar_cyan',
      equippedTrail: json['equippedTrail'] as String? ?? 'default',
      selectedThemeId: json['selectedThemeId'] as String? ?? 'neon_aqua',
      achievementsCompleted:
          (json['achievementsCompleted'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v as bool)) ??
              {},
      achievementsClaimed:
          (json['achievementsClaimed'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v as bool)) ??
              {},
      dailyRewardDay: json['dailyRewardDay'] as int? ?? 1,
      lastDailyRewardClaim: json['lastDailyRewardClaim'] != null
          ? DateTime.parse(json['lastDailyRewardClaim'] as String)
          : null,
      dailyChallengeBestDistance:
          json['dailyChallengeBestDistance'] as int? ?? 0,
      dailyChallengeBestScore:
          json['dailyChallengeBestScore'] as int? ?? 0,
      lastDailyChallengeDate: json['lastDailyChallengeDate'] != null
          ? DateTime.parse(json['lastDailyChallengeDate'] as String)
          : null,
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
      totalPlayTimeSeconds: json['totalPlayTimeSeconds'] as int? ?? 0,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.7,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 1.0,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      graphicsQuality: json['graphicsQuality'] as String? ?? 'high',
      controlSensitivity:
          (json['controlSensitivity'] as num?)?.toDouble() ?? 1.0,
      accelerometerEnabled:
          json['accelerometerEnabled'] as bool? ?? false,
      leftHandedLayout: json['leftHandedLayout'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      dataVersion: json['dataVersion'] as int? ?? 2,
    );
  }
}
