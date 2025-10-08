import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/learning_statistics_repository.dart';
import '../../core/database/learning_record_repository.dart';
import '../../core/database/grammar_progress_repository.dart';

/// 总体学习统计
class LearningStatistics {
  final int totalWordsLearned;
  final int totalWordsReviewed;
  final int totalGrammarStudied;
  final int totalConversationMessages;
  final int totalStudyDays;
  final int studyStreak;
  final int totalStudyTimeMinutes;
  final List<DailyStatistics> recentStats;

  LearningStatistics({
    required this.totalWordsLearned,
    required this.totalWordsReviewed,
    required this.totalGrammarStudied,
    required this.totalConversationMessages,
    required this.totalStudyDays,
    required this.studyStreak,
    required this.totalStudyTimeMinutes,
    required this.recentStats,
  });

  double get averageStudyTimePerDay {
    if (totalStudyDays == 0) return 0;
    return totalStudyTimeMinutes / totalStudyDays;
  }
}

/// Provider for learning statistics
final statisticsProvider = FutureProvider<LearningStatistics>((ref) async {
  final statsRepo = LearningStatisticsRepository();

  // 获取最近7天的统计数据
  final recentStats = await statsRepo.getRecentStatistics(7);

  // 计算总数
  int totalWordsLearned = 0;
  int totalWordsReviewed = 0;
  int totalGrammarStudied = 0;
  int totalConversationMessages = 0;

  for (var stat in recentStats) {
    totalWordsLearned += stat.wordsLearned;
    totalWordsReviewed += stat.wordsReviewed;
    totalGrammarStudied += stat.grammarPointsStudied;
    totalConversationMessages += stat.conversationMessages;
  }

  // 获取其他统计
  final totalStudyDays = await statsRepo.getTotalStudyDays();
  final studyStreak = await statsRepo.getStudyStreak();
  final totalStudyTime = await statsRepo.getTotalStudyTime();

  return LearningStatistics(
    totalWordsLearned: totalWordsLearned,
    totalWordsReviewed: totalWordsReviewed,
    totalGrammarStudied: totalGrammarStudied,
    totalConversationMessages: totalConversationMessages,
    totalStudyDays: totalStudyDays,
    studyStreak: studyStreak,
    totalStudyTimeMinutes: totalStudyTime,
    recentStats: recentStats,
  );
});

/// Provider for today's statistics
final todayStatisticsProvider = FutureProvider<DailyStatistics?>((ref) async {
  final statsRepo = LearningStatisticsRepository();
  return await statsRepo.getStatistics(DateTime.now());
});

/// Provider for vocabulary statistics
final vocabularyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = LearningRecordRepository();

  final allRecords = await repo.getAllLearningRecords();
  final totalWords = allRecords.length;

  int masteredWords = 0;
  int reviewingWords = 0;
  double totalMastery = 0;

  for (var record in allRecords.values) {
    totalMastery += record.mastery;
    if (record.mastery >= 0.8) {
      masteredWords++;
    } else if (record.reviewCount > 0) {
      reviewingWords++;
    }
  }

  final averageMastery = totalWords > 0 ? totalMastery / totalWords : 0.0;

  return {
    'totalWords': totalWords,
    'masteredWords': masteredWords,
    'reviewingWords': reviewingWords,
    'averageMastery': averageMastery,
  };
});

/// Provider for grammar statistics
final grammarStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = GrammarProgressRepository();

  final completedCount = await repo.getCompletedCount();
  final favoriteCount = await repo.getFavoriteCount();

  return {
    'completedCount': completedCount,
    'favoriteCount': favoriteCount,
  };
});
