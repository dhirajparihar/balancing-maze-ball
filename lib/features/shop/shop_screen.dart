/// In-game shop screen — purchase and equip Marble Skins, Trails, Themes, and Power-ups.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/game_service.dart';
import '../../models/shop_item.dart';
import '../../models/theme_data.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/neon_button.dart';

class ShopScreen extends StatefulWidget {
  final GameService gameService;

  const ShopScreen({super.key, required this.gameService});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerHaptic(void Function() call) {
    if (widget.gameService.playerData.vibrationEnabled) {
      call();
    }
  }

  void _buyOrEquipMarble(ShopItem item) async {
    final owns = widget.gameService.ownsItem(item.id);
    if (owns) {
      _triggerHaptic(() => HapticFeedback.lightImpact());
      await widget.gameService.equipItem(item.id);
      setState(() {});
      return;
    }

    if (!widget.gameService.canAfford(item.price)) {
      _triggerHaptic(() => HapticFeedback.vibrate());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins! Play levels to earn more.'),
          backgroundColor: Color(0xFFE53935),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final success = await widget.gameService.purchaseItem(item.id);
    if (success && mounted) {
      _triggerHaptic(() => HapticFeedback.heavyImpact());
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unlocked ${item.name}!'),
          backgroundColor: const Color(0xFF00E676),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _buyOrEquipTheme(MazeThemeData theme) async {
    final isUnlocked = widget.gameService.isThemeUnlocked(theme.id);
    if (isUnlocked) {
      _triggerHaptic(() => HapticFeedback.lightImpact());
      await widget.gameService.selectTheme(theme.id);
      setState(() {});
      return;
    }

    if (!widget.gameService.canAfford(theme.unlockCost)) {
      _triggerHaptic(() => HapticFeedback.vibrate());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins for this theme!'),
          backgroundColor: Color(0xFFE53935),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final success = await widget.gameService.unlockTheme(theme.id, theme.unlockCost);
    if (success && mounted) {
      _triggerHaptic(() => HapticFeedback.heavyImpact());
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unlocked ${theme.name} theme!'),
          backgroundColor: const Color(0xFF00E676),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08121E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  const Text(
                    'SHOP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                    ),
                  ),
                  CoinBadge(coins: widget.gameService.playerData.coins),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00E5FF),
              indicatorWeight: 3,
              labelColor: const Color(0xFF00E5FF),
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Skins'),
                Tab(text: 'Trails'),
                Tab(text: 'Themes'),
              ],
            ),

            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSkinsTab(),
                  _buildTrailsTab(),
                  _buildThemesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinsTab() {
    final skins = ShopInventory.marbleSkins;
    final equipped = widget.gameService.playerData.equippedMarbleSkin;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: skins.length,
      itemBuilder: (context, index) {
        final item = skins[index];
        final owns = widget.gameService.ownsItem(item.id);
        final isEquipped = equipped == item.id;

        return GlassPanel(
          padding: const EdgeInsets.all(12),
          borderRadius: 18,
          borderColor: isEquipped ? const Color(0xFF00E5FF) : Colors.white12,
          backgroundColor: isEquipped ? const Color(0x2200E5FF) : Colors.black.withValues(alpha: 0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Marble Preview Sphere
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.4),
                    colors: _getMarbleColors(item.id),
                    stops: const [0.0, 0.4, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getMarbleColors(item.id)[1].withValues(alpha: 0.6),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),

              // Title & Desc
              Column(
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),

              // Action Button
              NeonButton(
                height: 36,
                onPressed: () => _buyOrEquipMarble(item),
                primaryColor: isEquipped
                    ? const Color(0xFF00E676)
                    : (owns ? const Color(0xFF00E5FF) : const Color(0xFFFFB74D)),
                child: Text(
                  isEquipped
                      ? 'EQUIPPED'
                      : (owns ? 'EQUIP' : '${item.price} Coins'),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrailsTab() {
    final trails = ShopInventory.trails;
    final equipped = widget.gameService.playerData.equippedTrail;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trails.length,
      itemBuilder: (context, index) {
        final item = trails[index];
        final owns = widget.gameService.ownsItem(item.id);
        final isEquipped = equipped == item.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassPanel(
            borderRadius: 16,
            borderColor: isEquipped ? const Color(0xFF00E5FF) : Colors.white12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: const Color(0xFF00E5FF), size: 28),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(item.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: 100,
                  height: 38,
                  child: NeonButton(
                    height: 38,
                    onPressed: () => _buyOrEquipMarble(item),
                    primaryColor: isEquipped
                        ? const Color(0xFF00E676)
                        : (owns ? const Color(0xFF00E5FF) : const Color(0xFFFFB74D)),
                    child: Text(
                      isEquipped ? 'EQUIPPED' : (owns ? 'EQUIP' : '${item.price}'),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemesTab() {
    final themes = GameThemes.all;
    final selectedId = widget.gameService.playerData.selectedThemeId;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isUnlocked = widget.gameService.isThemeUnlocked(theme.id);
        final isSelected = selectedId == theme.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: GlassPanel(
            borderColor: isSelected ? theme.wallGlowColor : Colors.white12,
            backgroundColor: theme.backgroundColor.withValues(alpha: 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Theme color palette indicator dots
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.wallGlowColor, width: 1.5),
                        color: theme.backgroundColor,
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.wallGlowColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            shadows: [Shadow(color: theme.wallGlowColor, blurRadius: 8)],
                          ),
                        ),
                        Text(theme.description, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: 110,
                  height: 38,
                  child: NeonButton(
                    height: 38,
                    onPressed: () => _buyOrEquipTheme(theme),
                    primaryColor: isSelected
                        ? const Color(0xFF00E676)
                        : (isUnlocked ? theme.wallGlowColor : const Color(0xFFFFB74D)),
                    child: Text(
                      isSelected
                          ? 'ACTIVE'
                          : (isUnlocked ? 'SELECT' : '${theme.unlockCost} Coins'),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  List<Color> _getMarbleColors(String skinId) {
    switch (skinId) {
      case 'marble_gold':
        return [Colors.white, const Color(0xFFFFD700), const Color(0xFFB78103)];
      case 'marble_ruby':
        return [Colors.white, const Color(0xFFFF1744), const Color(0xFF880E4F)];
      case 'marble_sapphire':
        return [Colors.white, const Color(0xFF00B0FF), const Color(0xFF0D47A1)];
      case 'marble_emerald':
        return [Colors.white, const Color(0xFF00E676), const Color(0xFF1B5E20)];
      case 'marble_neon':
        return [Colors.white, const Color(0xFF00E5FF), const Color(0xFFE040FB)];
      case 'marble_galaxy':
        return [const Color(0xFFE040FB), const Color(0xFF3D5AFE), const Color(0xFF050520)];
      case 'marble_crystal':
        return [Colors.white, const Color(0xFFE0F7FA), const Color(0xFF80DEEA)];
      default:
        return [Colors.white, const Color(0xFFCFD8DC), const Color(0xFF546E7A)];
    }
  }
}
