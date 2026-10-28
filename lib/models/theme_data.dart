/// Theme data model for visual themes (Neon Aqua, Cyberpunk, etc.).
library;

import 'dart:ui';

class MazeThemeData {
  final String id;
  final String name;
  final String description;
  final Color backgroundColor;
  final Color wallColor;
  final Color wallGlowColor;
  final Color boardFrameColor;
  final Color marbleBaseColor;
  final Color marbleHighlightColor;
  final Color coinColor;
  final Color exitColor;
  final Color hazardColor;
  final Color textColor;
  final Color accentColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color hudBackgroundColor;
  final Color hudTextColor;
  final Color particleColor;
  final Color trailColor;
  final int unlockCost;
  final bool isDefault;
  final int requiredStars;

  const MazeThemeData({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundColor,
    required this.wallColor,
    required this.wallGlowColor,
    required this.boardFrameColor,
    required this.marbleBaseColor,
    required this.marbleHighlightColor,
    required this.coinColor,
    required this.exitColor,
    required this.hazardColor,
    required this.textColor,
    required this.accentColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.hudBackgroundColor,
    required this.hudTextColor,
    required this.particleColor,
    required this.trailColor,
    this.unlockCost = 0,
    this.isDefault = false,
    this.requiredStars = 0,
  });
}

/// All 8 game themes.
class GameThemes {
  GameThemes._();

  static const neonAqua = MazeThemeData(
    id: 'neon_aqua',
    name: 'Neon Aqua',
    description: 'Turquoise metal, cyan glow, navy background',
    backgroundColor: Color(0xFF0A1628),
    wallColor: Color(0xFF1A6E7A),
    wallGlowColor: Color(0xFF00E5FF),
    boardFrameColor: Color(0xFF2A3A4A),
    marbleBaseColor: Color(0xFFB0BEC5),
    marbleHighlightColor: Color(0xFFFFFFFF),
    coinColor: Color(0xFFFFD54F),
    exitColor: Color(0xFF00E676),
    hazardColor: Color(0xFFFF5252),
    textColor: Color(0xFF00E5FF),
    accentColor: Color(0xFFFFAB40),
    buttonColor: Color(0xFFFF8F00),
    buttonTextColor: Color(0xFFFFFFFF),
    hudBackgroundColor: Color(0x99102030),
    hudTextColor: Color(0xFF80DEEA),
    particleColor: Color(0xFF00E5FF),
    trailColor: Color(0x8800E5FF),
    isDefault: true,
  );

  static const cyberpunkCity = MazeThemeData(
    id: 'cyberpunk_city',
    name: 'Cyberpunk City',
    description: 'Purple, blue, pink, and green neon',
    backgroundColor: Color(0xFF0D0221),
    wallColor: Color(0xFF6A1B9A),
    wallGlowColor: Color(0xFFE040FB),
    boardFrameColor: Color(0xFF1A0A3A),
    marbleBaseColor: Color(0xFFE0E0E0),
    marbleHighlightColor: Color(0xFFE040FB),
    coinColor: Color(0xFF76FF03),
    exitColor: Color(0xFF00E5FF),
    hazardColor: Color(0xFFFF1744),
    textColor: Color(0xFFE040FB),
    accentColor: Color(0xFF76FF03),
    buttonColor: Color(0xFF7C4DFF),
    buttonTextColor: Color(0xFFFFFFFF),
    hudBackgroundColor: Color(0x990D0221),
    hudTextColor: Color(0xFFCE93D8),
    particleColor: Color(0xFFE040FB),
    trailColor: Color(0x88E040FB),
    unlockCost: 1000,
    requiredStars: 10,
  );

  static const cosmicGalaxy = MazeThemeData(
    id: 'cosmic_galaxy',
    name: 'Cosmic Galaxy',
    description: 'Stars, nebulae, purple and blue effects',
    backgroundColor: Color(0xFF050520),
    wallColor: Color(0xFF283593),
    wallGlowColor: Color(0xFF448AFF),
    boardFrameColor: Color(0xFF1A237E),
    marbleBaseColor: Color(0xFFE8EAF6),
    marbleHighlightColor: Color(0xFF82B1FF),
    coinColor: Color(0xFFFFD740),
    exitColor: Color(0xFF69F0AE),
    hazardColor: Color(0xFFFF6E40),
    textColor: Color(0xFF82B1FF),
    accentColor: Color(0xFFB388FF),
    buttonColor: Color(0xFF304FFE),
    buttonTextColor: Color(0xFFFFFFFF),
    hudBackgroundColor: Color(0x99050520),
    hudTextColor: Color(0xFF9FA8DA),
    particleColor: Color(0xFF82B1FF),
    trailColor: Color(0x8882B1FF),
    unlockCost: 1500,
    requiredStars: 25,
  );

  static const candyDream = MazeThemeData(
    id: 'candy_dream',
    name: 'Candy Dream',
    description: 'Pastel pink, turquoise, frosting, and sprinkles',
    backgroundColor: Color(0xFFFFF0F5),
    wallColor: Color(0xFFF48FB1),
    wallGlowColor: Color(0xFFFF80AB),
    boardFrameColor: Color(0xFFE1BEE7),
    marbleBaseColor: Color(0xFFFFFFFF),
    marbleHighlightColor: Color(0xFFF8BBD0),
    coinColor: Color(0xFFFFD54F),
    exitColor: Color(0xFF80CBC4),
    hazardColor: Color(0xFFEF5350),
    textColor: Color(0xFFAD1457),
    accentColor: Color(0xFF80DEEA),
    buttonColor: Color(0xFFF06292),
    buttonTextColor: Color(0xFFFFFFFF),
    hudBackgroundColor: Color(0x99FFF0F5),
    hudTextColor: Color(0xFFAD1457),
    particleColor: Color(0xFFFF80AB),
    trailColor: Color(0x88FF80AB),
    unlockCost: 2000,
    requiredStars: 40,
  );

  static const enchantedForest = MazeThemeData(
    id: 'enchanted_forest',
    name: 'Enchanted Forest',
    description: 'Wood, vines, moss, and leaves',
    backgroundColor: Color(0xFF1B2A1B),
    wallColor: Color(0xFF5D4037),
    wallGlowColor: Color(0xFF66BB6A),
    boardFrameColor: Color(0xFF3E2723),
    marbleBaseColor: Color(0xFF8D6E63),
    marbleHighlightColor: Color(0xFFA1887F),
    coinColor: Color(0xFFFFD54F),
    exitColor: Color(0xFF81C784),
    hazardColor: Color(0xFFFF7043),
    textColor: Color(0xFF81C784),
    accentColor: Color(0xFFA5D6A7),
    buttonColor: Color(0xFF2E7D32),
    buttonTextColor: Color(0xFFFFFFFF),
    hudBackgroundColor: Color(0x991B2A1B),
    hudTextColor: Color(0xFFA5D6A7),
    particleColor: Color(0xFF66BB6A),
    trailColor: Color(0x8866BB6A),
    unlockCost: 2500,
    requiredStars: 55,
  );

  static const desertRelics = MazeThemeData(
    id: 'desert_relics',
    name: 'Desert Relics',
    description: 'Sandstone, golden light, and ancient carvings',
    backgroundColor: Color(0xFF2C1810),
    wallColor: Color(0xFFD4A574),
    wallGlowColor: Color(0xFFFFB74D),
    boardFrameColor: Color(0xFF4E342E),
    marbleBaseColor: Color(0xFFF5E6D3),
    marbleHighlightColor: Color(0xFFFFD54F),
    coinColor: Color(0xFFFFD740),
    exitColor: Color(0xFF81D4FA),
    hazardColor: Color(0xFFFF5722),
    textColor: Color(0xFFFFB74D),
    accentColor: Color(0xFFFFCC80),
    buttonColor: Color(0xFFE65100),
    buttonTextColor: Color(0xFFFFFFFF),
    hudBackgroundColor: Color(0x992C1810),
    hudTextColor: Color(0xFFFFCC80),
    particleColor: Color(0xFFFFB74D),
    trailColor: Color(0x88FFB74D),
    unlockCost: 2500,
    requiredStars: 70,
  );

  static const steampunkFoundry = MazeThemeData(
    id: 'steampunk_foundry',
    name: 'Steampunk Foundry',
    description: 'Brass, copper, gears, and steam',
    backgroundColor: Color(0xFF1A1408),
    wallColor: Color(0xFFB08040),
    wallGlowColor: Color(0xFFFFAB40),
    boardFrameColor: Color(0xFF3A2A10),
    marbleBaseColor: Color(0xFFC0A060),
    marbleHighlightColor: Color(0xFFFFD54F),
    coinColor: Color(0xFFFFD740),
    exitColor: Color(0xFF80CBC4),
    hazardColor: Color(0xFFFF6E40),
    textColor: Color(0xFFFFAB40),
    accentColor: Color(0xFFFFCC80),
    buttonColor: Color(0xFF795548),
    buttonTextColor: Color(0xFFFFFFFF),
    hudBackgroundColor: Color(0x991A1408),
    hudTextColor: Color(0xFFFFCC80),
    particleColor: Color(0xFFFFAB40),
    trailColor: Color(0x88FFAB40),
    unlockCost: 3000,
    requiredStars: 85,
  );

  static const deepOcean = MazeThemeData(
    id: 'deep_ocean',
    name: 'Deep Ocean',
    description: 'Aquatic blue, coral, bubbles, and underwater light',
    backgroundColor: Color(0xFF001830),
    wallColor: Color(0xFF006064),
    wallGlowColor: Color(0xFF00BCD4),
    boardFrameColor: Color(0xFF004D40),
    marbleBaseColor: Color(0xFFE0F7FA),
    marbleHighlightColor: Color(0xFF80DEEA),
    coinColor: Color(0xFFFFD54F),
    exitColor: Color(0xFF64FFDA),
    hazardColor: Color(0xFFFF5252),
    textColor: Color(0xFF4DD0E1),
    accentColor: Color(0xFF80CBC4),
    buttonColor: Color(0xFF00695C),
    buttonTextColor: Color(0xFFFFFFFF),
    hudBackgroundColor: Color(0x99001830),
    hudTextColor: Color(0xFF80CBC4),
    particleColor: Color(0xFF00BCD4),
    trailColor: Color(0x8800BCD4),
    unlockCost: 3000,
    requiredStars: 100,
  );

  static List<MazeThemeData> get all => [
        neonAqua,
        cyberpunkCity,
        cosmicGalaxy,
        candyDream,
        enchantedForest,
        desertRelics,
        steampunkFoundry,
        deepOcean,
      ];

  static MazeThemeData getById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => neonAqua);
  }
}
