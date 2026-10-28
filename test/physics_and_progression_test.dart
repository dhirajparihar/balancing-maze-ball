import 'package:flutter_test/flutter_test.dart';
import 'package:balancing_maze/game/systems/level_definitions.dart';
import 'package:balancing_maze/models/maze_theme_config.dart';

void main() {
  group('Balancing Maze Heavy Mechanics & Level Layout', () {
    test('Master Organic (Level 4) preserves safe starting resting shelf', () {
      final level = LevelDefinitions.level4MasterOrganic;

      expect(level.barStartY, 48.0);
      expect(level.barGoalY, 17.5);
      expect(level.marbleStartPos.dx, 14.0);
      expect(level.marbleStartPos.dy, 45.95);

      // Verify no hole intrudes into the solid starting resting shelf (y = 43.0 to y = 54.5)
      for (final hole in level.holes) {
        final bounds = hole.createPath().getBounds();
        final overlapsShelf = bounds.top < 54.5 && bounds.bottom > 43.0;
        expect(
          overlapsShelf,
          isFalse,
          reason: 'Hole ${hole.id} intrudes into resting shelf between y=43.0 and y=54.5',
        );
      }
    });

    test('Taped Hole Shield mechanics work as specified', () {
      final level = LevelDefinitions.level1Training;
      final tapedHoles = level.holes.where((h) => h.isTaped).toList();

      expect(tapedHoles.isNotEmpty, isTrue);
      final firstTaped = tapedHoles.first;
      expect(firstTaped.isTapeBroken, isFalse);

      firstTaped.breakTape();
      expect(firstTaped.isTapeBroken, isTrue);

      firstTaped.resetTape();
      expect(firstTaped.isTapeBroken, isFalse);
    });

    test('Theme configurations contain all 6 physical and visual styles', () {
      expect(MazeThemeConfig.allThemes.length, 6);

      final classic = MazeThemeConfig.getById('classic_cyan');
      expect(classic.type, ThemeType.classicCyan);

      final steampunk = MazeThemeConfig.getById('steampunk_brass');
      expect(steampunk.type, ThemeType.steampunkBrass);

      final jungle = MazeThemeConfig.getById('jungle_bamboo');
      expect(jungle.type, ThemeType.jungleBamboo);

      final cyberpunk = MazeThemeConfig.getById('cyberpunk_neon');
      expect(cyberpunk.type, ThemeType.cyberpunkNeon);
    });
  });
}
