import 'package:flutter/material.dart';

/// Balance Runner skin and bar style specifications
class BallSkinDef {
  final String id;
  final String name;
  final int cost;
  final List<Color> gradientColors;
  final List<double> stops;
  final Color glowColor;
  final bool isSpecialPattern; // e.g., soccer or carbon

  const BallSkinDef({
    required this.id,
    required this.name,
    required this.cost,
    required this.gradientColors,
    required this.stops,
    required this.glowColor,
    this.isSpecialPattern = false,
  });

  static const List<BallSkinDef> allSkins = [
    BallSkinDef(
      id: 'classic_metallic',
      name: 'Classic Metallic',
      cost: 0,
      gradientColors: [
        Colors.white,
        Color(0xFFE2E8F0),
        Color(0xFF94A3B8),
        Color(0xFF475569),
      ],
      stops: [0.0, 0.35, 0.7, 1.0],
      glowColor: Color(0xFFE2E8F0),
    ),
    BallSkinDef(
      id: 'neon_cyan',
      name: 'Neon Cyan',
      cost: 0,
      gradientColors: [
        Color(0xFFE0FFFF),
        Color(0xFF00E5FF),
        Color(0xFF0091EA),
        Color(0xFF006064),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
      glowColor: Color(0xFF00E5FF),
    ),
    BallSkinDef(
      id: 'gold_glow',
      name: 'Golden Glow',
      cost: 600,
      gradientColors: [
        Color(0xFFFFF9C4),
        Color(0xFFFFD700),
        Color(0xFFFF8F00),
        Color(0xFF7E4200),
      ],
      stops: [0.0, 0.35, 0.75, 1.0],
      glowColor: Color(0xFFFFD700),
    ),
    BallSkinDef(
      id: 'amethyst',
      name: 'Amethyst Crystal',
      cost: 800,
      gradientColors: [
        Color(0xFFF3E5F5),
        Color(0xFFAB47BC),
        Color(0xFF7B1FA2),
        Color(0xFF4A148C),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
      glowColor: Color(0xFFD500F9),
    ),
    BallSkinDef(
      id: 'cyber_soccer',
      name: 'Cyber Soccer',
      cost: 1000,
      gradientColors: [
        Colors.white,
        Color(0xFFCFD8DC),
        Color(0xFF37474F),
        Color(0xFF212121),
      ],
      stops: [0.0, 0.4, 0.75, 1.0],
      glowColor: Color(0xFF00E5FF),
      isSpecialPattern: true,
    ),
    BallSkinDef(
      id: 'carbon_fiber',
      name: 'Carbon Fiber',
      cost: 1200,
      gradientColors: [
        Color(0xFF78909C),
        Color(0xFF37474F),
        Color(0xFF263238),
        Color(0xFF101820),
      ],
      stops: [0.0, 0.35, 0.7, 1.0],
      glowColor: Color(0xFF546E7A),
      isSpecialPattern: true,
    ),
    BallSkinDef(
      id: 'solar_fire',
      name: 'Solar Fire',
      cost: 1500,
      gradientColors: [
        Color(0xFFFFF176),
        Color(0xFFFF7043),
        Color(0xFFD50000),
        Color(0xFF5D0000),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
      glowColor: Color(0xFFFF3D00),
    ),
    BallSkinDef(
      id: 'emerald',
      name: 'Emerald Core',
      cost: 1800,
      gradientColors: [
        Color(0xFFE8F5E9),
        Color(0xFF00E676),
        Color(0xFF00C853),
        Color(0xFF004D20),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
      glowColor: Color(0xFF00E676),
    ),
  ];

  static BallSkinDef getById(String id) {
    return allSkins.firstWhere(
      (s) => s.id == id,
      orElse: () => allSkins.first,
    );
  }
}

class BarStyleDef {
  final String id;
  final String name;
  final int cost;
  final Color primaryColor;
  final Color glowColor;
  final List<Color> rodGradient;

  const BarStyleDef({
    required this.id,
    required this.name,
    required this.cost,
    required this.primaryColor,
    required this.glowColor,
    required this.rodGradient,
  });

  static const List<BarStyleDef> allStyles = [
    BarStyleDef(
      id: 'bar_cyan',
      name: 'Cyan Glow',
      cost: 0,
      primaryColor: Color(0xFF00E5FF),
      glowColor: Color(0xFF00E5FF),
      rodGradient: [Color(0xFF80DEEA), Color(0xFF00E5FF), Color(0xFF006064)],
    ),
    BarStyleDef(
      id: 'bar_orange',
      name: 'Amber Blaze',
      cost: 500,
      primaryColor: Color(0xFFFF9100),
      glowColor: Color(0xFFFF6D00),
      rodGradient: [Color(0xFFFFD180), Color(0xFFFF9100), Color(0xFFBF360C)],
    ),
    BarStyleDef(
      id: 'bar_prism',
      name: 'Prism Rainbow',
      cost: 1200,
      primaryColor: Color(0xFFE040FB),
      glowColor: Color(0xFF7C4DFF),
      rodGradient: [
        Color(0xFFFF5252),
        Color(0xFFFFD740),
        Color(0xFF69F0AE),
        Color(0xFF40C4FF),
        Color(0xFFE040FB),
      ],
    ),
    BarStyleDef(
      id: 'bar_dark',
      name: 'Stealth Matte',
      cost: 1600,
      primaryColor: Color(0xFF90A4AE),
      glowColor: Color(0xFF37474F),
      rodGradient: [Color(0xFF607D8B), Color(0xFF263238), Color(0xFF0F171E)],
    ),
  ];

  static BarStyleDef getById(String id) {
    return allStyles.firstWhere(
      (s) => s.id == id,
      orElse: () => allStyles.first,
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String playerName;
  final int distanceMeters;
  final int score;
  final String avatarUrl;
  final bool isUser;

  const LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.distanceMeters,
    required this.score,
    required this.avatarUrl,
    this.isUser = false,
  });
}
