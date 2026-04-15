import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProgressService', () {
    late ProgressService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = ProgressService();
    });

    test('getProgress returns defaults when no data stored', () async {
      final progress = await service.getProgress();
      expect(progress.signsPracticed, 0);
      expect(progress.currentStreak, 0);
      expect(progress.bestStreak, 0);
      expect(progress.totalScore, 0);
      expect(progress.level, 1);
      expect(progress.lastPracticeDate, isNull);
    });

    test('recordPractice increments signs practiced', () async {
      final p1 = await service.recordPractice(scoreGained: 10);
      expect(p1.signsPracticed, 1);
      final p2 = await service.recordPractice(scoreGained: 10);
      expect(p2.signsPracticed, 2);
    });

    test('recordPractice adds score', () async {
      final p = await service.recordPractice(scoreGained: 25);
      expect(p.totalScore, 25);
    });

    test('recordPractice accumulates score', () async {
      await service.recordPractice(scoreGained: 50);
      final p = await service.recordPractice(scoreGained: 50);
      expect(p.totalScore, 100);
    });

    test('recordPractice starts streak at 1 on first call', () async {
      final p = await service.recordPractice();
      expect(p.currentStreak, 1);
    });

    test('level increases with score', () async {
      // Level 2 starts at 100 points
      UserProgress? p;
      for (int i = 0; i < 9; i++) {
        p = await service.recordPractice(scoreGained: 10);
      }
      expect(p!.level, 1); // 90 pts = still level 1
      p = await service.recordPractice(scoreGained: 10);
      expect(p.level, 2); // 100 pts = level 2
    });
  });

  group('UserProgress', () {
    test('levelName returns correct name for each level', () {
      const expected = [
        'Beginner',
        'Novice',
        'Learner',
        'Intermediate',
        'Skilled',
        'Advanced',
        'Expert',
        'Master',
        'Grandmaster',
        'Legend',
      ];
      for (int i = 1; i <= 10; i++) {
        final p = UserProgress(
          signsPracticed: 0,
          currentStreak: 0,
          totalScore: 0,
          level: i,
        );
        expect(p.levelName, expected[i - 1], reason: 'Level $i');
      }
    });

    test('nextLevelScore returns correct thresholds', () {
      final p1 = UserProgress(
          signsPracticed: 0, currentStreak: 0, totalScore: 0, level: 1);
      expect(p1.nextLevelScore, 100);

      final p5 = UserProgress(
          signsPracticed: 0, currentStreak: 0, totalScore: 0, level: 5);
      expect(p5.nextLevelScore, 1500);
    });

    test('levelProgress is 0 at start of level', () {
      final p = UserProgress(
          signsPracticed: 0, currentStreak: 0, totalScore: 0, level: 1);
      expect(p.levelProgress, 0.0);
    });

    test('levelProgress is 0.5 at midpoint', () {
      final p = UserProgress(
          signsPracticed: 0, currentStreak: 0, totalScore: 50, level: 1);
      expect(p.levelProgress, 0.5);
    });

    test('levelProgress clamps to 1.0', () {
      final p = UserProgress(
          signsPracticed: 0, currentStreak: 0, totalScore: 999, level: 1);
      expect(p.levelProgress, 1.0);
    });

    test('bestStreak defaults to 0', () {
      final p = UserProgress(
          signsPracticed: 0, currentStreak: 0, totalScore: 0, level: 1);
      expect(p.bestStreak, 0);
    });
  });
}
