import 'package:flutter_test/flutter_test.dart';
import 'package:balancing_maze/game/systems/level_definitions.dart';
import 'package:balancing_maze/models/level_config.dart';

void main() {
  group('Level Definitions Integrity & Safe Lookup', () {
    test('Contains exactly 6 handcrafted campaign levels', () {
      expect(LevelDefinitions.allLevels.length, 6);
      for (int i = 0; i < LevelDefinitions.allLevels.length; i++) {
        expect(LevelDefinitions.allLevels[i].id, i + 1);
      }
    });

    test('Valid IDs return corresponding levels', () {
      for (int i = 1; i <= 6; i++) {
        expect(LevelDefinitions.hasLevel(i), isTrue);
        final level = LevelDefinitions.getById(i);
        expect(level.id, i);
        expect(level.holes.isNotEmpty, isTrue);
        expect(level.getGoalHole(), isNotNull);
        expect(level.parTimeSeconds, greaterThan(20.0));
      }
    });

    test('Daily challenge ID 999 is recognized and valid', () {
      expect(LevelDefinitions.hasLevel(999), isTrue);
      final challenge = LevelDefinitions.getById(999);
      expect(challenge.id, 999);
      expect(challenge.mode, LevelMode.dailyChallenge);
    });

    test('Unknown IDs (e.g. 7, 30) throw ArgumentError rather than silently substituting Level 4', () {
      expect(LevelDefinitions.hasLevel(7), isFalse);
      expect(LevelDefinitions.hasLevel(30), isFalse);
      expect(LevelDefinitions.hasLevel(0), isFalse);

      expect(LevelDefinitions.tryGetById(7), isNull);
      expect(LevelDefinitions.tryGetById(30), isNull);

      expect(() => LevelDefinitions.getById(7), throwsArgumentError);
      expect(() => LevelDefinitions.getById(30), throwsArgumentError);
    });

    test('All levels have valid mechanical geometry and resting shelves', () {
      for (final level in LevelDefinitions.allLevels) {
        expect(level.railLeftX, lessThan(level.railRightX));
        expect(level.barStartY, greaterThan(level.barGoalY));
        expect(level.marbleStartPos.dx, greaterThanOrEqualTo(level.railLeftX));
        expect(level.marbleStartPos.dx, lessThanOrEqualTo(level.railRightX));
      }
    });

    test('All levels define deliberate pedagogical lesson objectives and skill briefs', () {
      for (final level in LevelDefinitions.allLevels) {
        expect(level.lessonObjective.isNotEmpty, isTrue, reason: 'Level ${level.id} missing lessonObjective');
        expect(level.skillBrief.isNotEmpty, isTrue, reason: 'Level ${level.id} missing skillBrief');
        expect(level.ghostPathHints.isNotEmpty, isTrue, reason: 'Level ${level.id} missing ghostPathHints');
      }
    });
  });
}
