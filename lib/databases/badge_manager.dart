import 'db_helper.dart';

class BadgeManager {
  // Singleton
  static final BadgeManager _instance = BadgeManager._internal();
  factory BadgeManager() => _instance;
  BadgeManager._internal();

  final DBHelper _db = DBHelper.instance;

  // ------------------- Unlock Functions -------------------

  Future<void> checkCompletionBadge() async {
    final count = await _db.getCompletedAssignmentsCount();
    if (count == 1) {
      await _db.unlockBadgeByName("Completion Badge");
    }
  }

  Future<void> checkQuizMaster(int score, int totalQuestions) async {
    if (score == totalQuestions * 10) {
      await _db.unlockBadgeByName("Quiz Master");
    }
  }

  Future<void> checkStreakKing(int streak) async {
    if (streak >= 5) {
      await _db.unlockBadgeByName("Streak King");
    }
  }

  Future<void> checkLearner(int viewedTopics, int totalTopics) async {
    if (viewedTopics >= totalTopics) {
      await _db.unlockBadgeByName("Learner");
    }
  }

  Future<void> checkConsistency(int consecutiveDays) async {
    if (consecutiveDays >= 7) {
      await _db.unlockBadgeByName("Consistency Badge");
    }
  }

  Future<void> checkMathGenius() async {
    final completedAssignments = await _db.getCompletedAssignmentsCount();
    final completedQuizzes = await _db.getCompletedQuizzesCount();
    if (completedAssignments + completedQuizzes >= 10) {
      await _db.unlockBadgeByName("Math Genius");
    }
  }

  // ------------------- Combined check -------------------
  Future<void> checkAll({int? streak, int? score, int? totalQuestions, int? viewedTopics, int? totalTopics, int? consecutiveDays}) async {
    await checkCompletionBadge();
    if (score != null && totalQuestions != null) await checkQuizMaster(score, totalQuestions);
    if (streak != null) await checkStreakKing(streak);
    if (viewedTopics != null && totalTopics != null) await checkLearner(viewedTopics, totalTopics);
    if (consecutiveDays != null) await checkConsistency(consecutiveDays);
    await checkMathGenius();
  }
}

