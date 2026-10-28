/// Shop item model.
library;

enum ShopCategory { marbleSkin, trail, boardCosmetic, theme, powerUp }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final ShopCategory category;
  final int price;
  final bool isPremium;
  final Map<String, dynamic>? visualData; // colors, effects config

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.isPremium = false,
    this.visualData,
  });
}

/// Predefined shop inventory.
class ShopInventory {
  ShopInventory._();

  static const List<ShopItem> marbleSkins = [
    ShopItem(
      id: 'marble_default',
      name: 'Classic Silver',
      description: 'The classic metallic marble.',
      category: ShopCategory.marbleSkin,
      price: 0,
    ),
    ShopItem(
      id: 'marble_gold',
      name: 'Golden Ball',
      description: 'A gleaming golden marble.',
      category: ShopCategory.marbleSkin,
      price: 500,
    ),
    ShopItem(
      id: 'marble_ruby',
      name: 'Ruby Sphere',
      description: 'Deep crimson with inner fire.',
      category: ShopCategory.marbleSkin,
      price: 750,
    ),
    ShopItem(
      id: 'marble_sapphire',
      name: 'Sapphire Orb',
      description: 'Ocean-deep blue brilliance.',
      category: ShopCategory.marbleSkin,
      price: 750,
    ),
    ShopItem(
      id: 'marble_emerald',
      name: 'Emerald Globe',
      description: 'Forest green with inner glow.',
      category: ShopCategory.marbleSkin,
      price: 750,
    ),
    ShopItem(
      id: 'marble_neon',
      name: 'Neon Pulse',
      description: 'Pulsating neon energy marble.',
      category: ShopCategory.marbleSkin,
      price: 1000,
      isPremium: true,
    ),
    ShopItem(
      id: 'marble_galaxy',
      name: 'Galaxy Core',
      description: 'Contains a miniature galaxy inside.',
      category: ShopCategory.marbleSkin,
      price: 1500,
      isPremium: true,
    ),
    ShopItem(
      id: 'marble_crystal',
      name: 'Crystal Clear',
      description: 'Transparent with prismatic refraction.',
      category: ShopCategory.marbleSkin,
      price: 1250,
      isPremium: true,
    ),
  ];

  static const List<ShopItem> trails = [
    ShopItem(
      id: 'trail_default',
      name: 'No Trail',
      description: 'Clean rolling, no trail.',
      category: ShopCategory.trail,
      price: 0,
    ),
    ShopItem(
      id: 'trail_spark',
      name: 'Spark Trail',
      description: 'Tiny sparks follow the marble.',
      category: ShopCategory.trail,
      price: 500,
    ),
    ShopItem(
      id: 'trail_glow',
      name: 'Glow Trail',
      description: 'Soft glowing light trail.',
      category: ShopCategory.trail,
      price: 600,
    ),
    ShopItem(
      id: 'trail_fire',
      name: 'Fire Trail',
      description: 'Burning ember particles.',
      category: ShopCategory.trail,
      price: 800,
    ),
    ShopItem(
      id: 'trail_ice',
      name: 'Ice Trail',
      description: 'Frozen crystal particles.',
      category: ShopCategory.trail,
      price: 800,
    ),
    ShopItem(
      id: 'trail_rainbow',
      name: 'Rainbow Trail',
      description: 'Colorful prismatic trail.',
      category: ShopCategory.trail,
      price: 1000,
      isPremium: true,
    ),
  ];

  static const List<ShopItem> powerUps = [
    ShopItem(
      id: 'powerup_shield',
      name: 'Shield',
      description: 'Protects from one hazard hit.',
      category: ShopCategory.powerUp,
      price: 100,
    ),
    ShopItem(
      id: 'powerup_slowtime',
      name: 'Slow Time',
      description: 'Slows the timer for 10 seconds.',
      category: ShopCategory.powerUp,
      price: 150,
    ),
    ShopItem(
      id: 'powerup_magnet',
      name: 'Coin Magnet',
      description: 'Attracts nearby coins.',
      category: ShopCategory.powerUp,
      price: 200,
    ),
    ShopItem(
      id: 'powerup_extratime',
      name: 'Extra Time',
      description: 'Adds 30 seconds to the timer.',
      category: ShopCategory.powerUp,
      price: 250,
    ),
  ];

  static List<ShopItem> get all => [
        ...marbleSkins,
        ...trails,
        ...powerUps,
      ];

  static ShopItem? getById(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
