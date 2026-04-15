import 'package:shared_preferences/shared_preferences.dart';

/// Tracks user learning progress with streaks, scores, and levels.
class ProgressService {
  static const _keySignsPracticed = 'signs_practiced';
  static const _keyCurrentStreak = 'current_streak';
  static const _keyLastPracticeDate = 'last_practice_date';
  static const _keyTotalScore = 'total_score';
  static const _keyLevel = 'level';
  static const _keyBestStreak = 'best_streak';

  Future<UserProgress> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProgress(
      signsPracticed: prefs.getInt(_keySignsPracticed) ?? 0,
      currentStreak: prefs.getInt(_keyCurrentStreak) ?? 0,
      bestStreak: prefs.getInt(_keyBestStreak) ?? 0,
      lastPracticeDate: prefs.getString(_keyLastPracticeDate),
      totalScore: prefs.getInt(_keyTotalScore) ?? 0,
      level: prefs.getInt(_keyLevel) ?? 1,
    );
  }

  /// Record one sign practice session. Manages daily streaks (local time):
  /// - First ever practice → streak = 1
  /// - Same day again → streak unchanged
  /// - Consecutive day → streak + 1
  /// - Gap > 1 day → streak resets to 1
  Future<UserProgress> recordPractice({int scoreGained = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final lastDate = prefs.getString(_keyLastPracticeDate);
    int streak = prefs.getInt(_keyCurrentStreak) ?? 0;

    if (lastDate == null) {
      streak = 1;
    } else if (lastDate != todayStr) {
      final last = DateTime.tryParse(lastDate);
      if (last != null) {
        final diff = now.difference(last).inDays;
        if (diff == 1) {
          streak += 1;
        } else if (diff > 1) {
          streak = 1;
        }
      } else {
        streak = 1;
      }
    }

    final signsPracticed = (prefs.getInt(_keySignsPracticed) ?? 0) + 1;
    final totalScore = (prefs.getInt(_keyTotalScore) ?? 0) + scoreGained;
    final level = _calculateLevel(totalScore);
    final bestStreak = prefs.getInt(_keyBestStreak) ?? 0;
    final newBest = streak > bestStreak ? streak : bestStreak;

    await prefs.setInt(_keySignsPracticed, signsPracticed);
    await prefs.setInt(_keyCurrentStreak, streak);
    await prefs.setInt(_keyBestStreak, newBest);
    await prefs.setString(_keyLastPracticeDate, todayStr);
    await prefs.setInt(_keyTotalScore, totalScore);
    await prefs.setInt(_keyLevel, level);

    return UserProgress(
      signsPracticed: signsPracticed,
      currentStreak: streak,
      bestStreak: newBest,
      lastPracticeDate: todayStr,
      totalScore: totalScore,
      level: level,
    );
  }

  /// Level thresholds: exponential curve so early levels feel fast,
  /// later levels require sustained effort.
  int _calculateLevel(int totalScore) {
    const thresholds = [0, 100, 300, 600, 1000, 1500, 2500, 4000, 6000, 9000];
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (totalScore >= thresholds[i]) return i + 1;
    }
    return 1;
  }
}

class UserProgress {
  final int signsPracticed;
  final int currentStreak;
  final int bestStreak;
  final String? lastPracticeDate;
  final int totalScore;
  final int level;

  UserProgress({
    required this.signsPracticed,
    required this.currentStreak,
    this.bestStreak = 0,
    this.lastPracticeDate,
    required this.totalScore,
    required this.level,
  });

  String get levelName {
    const names = [
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
    return names[(level - 1).clamp(0, 9)];
  }

  int get nextLevelScore {
    const thresholds = [
      100,
      300,
      600,
      1000,
      1500,
      2500,
      4000,
      6000,
      9000,
      99999,
    ];
    return thresholds[(level - 1).clamp(0, 9)];
  }

  double get levelProgress {
    const thresholds = [0, 100, 300, 600, 1000, 1500, 2500, 4000, 6000, 9000];
    final current = thresholds[(level - 1).clamp(0, 9)];
    final next = nextLevelScore;
    if (next <= current) return 1.0;
    return ((totalScore - current) / (next - current)).clamp(0.0, 1.0);
  }
}
