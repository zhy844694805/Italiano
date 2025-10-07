import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word.dart';
import '../../core/database/learning_record_repository.dart';

// 词汇服务
class VocabularyService {
  Future<List<Word>> loadWords() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/sample_words.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((json) => Word.fromJson(json)).toList();
    } catch (e) {
      print('Error loading words: $e');
      return [];
    }
  }

  Future<List<Word>> getWordsByLevel(String level) async {
    final words = await loadWords();
    return words.where((word) => word.level == level).toList();
  }

  Future<List<Word>> getWordsByCategory(String category) async {
    final words = await loadWords();
    return words.where((word) => word.category == category).toList();
  }
}

// Provider for vocabulary service
final vocabularyServiceProvider = Provider<VocabularyService>((ref) {
  return VocabularyService();
});

// Provider for all words
final allWordsProvider = FutureProvider<List<Word>>((ref) async {
  final service = ref.watch(vocabularyServiceProvider);
  return service.loadWords();
});

// Provider for words by level
final wordsByLevelProvider = FutureProvider.family<List<Word>, String>((ref, level) async {
  final service = ref.watch(vocabularyServiceProvider);
  return service.getWordsByLevel(level);
});

// Provider for words by category
final wordsByCategoryProvider = FutureProvider.family<List<Word>, String>((ref, category) async {
  final service = ref.watch(vocabularyServiceProvider);
  return service.getWordsByCategory(category);
});

// Repository provider
final learningRecordRepositoryProvider = Provider<LearningRecordRepository>((ref) {
  return LearningRecordRepository();
});

// Learning progress provider
class LearningProgressNotifier extends StateNotifier<Map<String, LearningRecord>> {
  final LearningRecordRepository _repository;

  LearningProgressNotifier(this._repository) : super({}) {
    _loadFromDatabase();
  }

  // 从数据库加载所有学习记录
  Future<void> _loadFromDatabase() async {
    final records = await _repository.getAllLearningRecords();
    state = records;
  }

  // 记录单词学习情况
  Future<void> recordWordStudied(Word word, bool correct) async {
    final existingRecord = state[word.id];

    final newRecord = existingRecord?.copyWith(
      lastReviewed: DateTime.now(),
      reviewCount: (existingRecord.reviewCount) + 1,
      correctCount: correct ? (existingRecord.correctCount) + 1 : existingRecord.correctCount,
      mastery: _calculateMastery(
        existingRecord.reviewCount + 1,
        correct ? existingRecord.correctCount + 1 : existingRecord.correctCount,
      ),
      nextReviewDate: _calculateNextReviewDate(
        existingRecord.reviewCount + 1,
        correct,
      ),
    ) ?? LearningRecord(
      wordId: word.id,
      lastReviewed: DateTime.now(),
      reviewCount: 1,
      correctCount: correct ? 1 : 0,
      mastery: correct ? 0.2 : 0.0,
      nextReviewDate: _calculateNextReviewDate(1, correct),
    );

    // 更新状态
    state = {...state, word.id: newRecord};

    // 保存到数据库
    await _repository.saveLearningRecord(newRecord);
  }

  // 切换收藏状态
  Future<void> toggleFavorite(String wordId) async {
    final record = state[wordId];
    final newRecord = record?.copyWith(isFavorite: !record.isFavorite) ??
      LearningRecord(
        wordId: wordId,
        lastReviewed: DateTime.now(),
        isFavorite: true,
      );

    // 更新状态
    state = {...state, wordId: newRecord};

    // 保存到数据库
    await _repository.saveLearningRecord(newRecord);
  }

  double _calculateMastery(int reviewCount, int correctCount) {
    if (reviewCount == 0) return 0.0;
    final accuracy = correctCount / reviewCount;
    final reviewFactor = (reviewCount / 10).clamp(0.0, 1.0);
    return (accuracy * 0.7 + reviewFactor * 0.3).clamp(0.0, 1.0);
  }

  DateTime _calculateNextReviewDate(int reviewCount, bool correct) {
    if (!correct) {
      // 如果答错，1小时后复习
      return DateTime.now().add(const Duration(hours: 1));
    }

    // 间隔重复算法
    final intervals = [
      Duration(hours: 4),      // 第1次：4小时后
      Duration(days: 1),       // 第2次：1天后
      Duration(days: 3),       // 第3次：3天后
      Duration(days: 7),       // 第4次：1周后
      Duration(days: 14),      // 第5次：2周后
      Duration(days: 30),      // 第6次：1月后
      Duration(days: 90),      // 第7次：3月后
    ];

    final index = (reviewCount - 1).clamp(0, intervals.length - 1);
    return DateTime.now().add(intervals[index]);
  }

  LearningRecord? getRecord(String wordId) {
    return state[wordId];
  }

  List<String> getStudiedWordIds() {
    return state.keys.toList();
  }

  List<String> getFavoriteWordIds() {
    return state.entries
        .where((entry) => entry.value.isFavorite)
        .map((entry) => entry.key)
        .toList();
  }

  // 获取需要复习的单词ID列表
  Future<List<String>> getWordsToReview() async {
    return await _repository.getWordsToReview();
  }

  // 获取学习统计
  Future<Map<String, dynamic>> getStatistics() async {
    return await _repository.getStatistics();
  }

  // 清空所有学习记录
  Future<void> clearAllProgress() async {
    await _repository.clearAll();
    state = {};
  }
}

final learningProgressProvider = StateNotifierProvider<LearningProgressNotifier, Map<String, LearningRecord>>((ref) {
  final repository = ref.watch(learningRecordRepositoryProvider);
  return LearningProgressNotifier(repository);
});

// Provider for words that need review
final wordsToReviewProvider = FutureProvider<List<Word>>((ref) async {
  final allWords = await ref.watch(allWordsProvider.future);
  final progressNotifier = ref.watch(learningProgressProvider.notifier);
  final wordIdsToReview = await progressNotifier.getWordsToReview();

  // 过滤出需要复习的单词
  return allWords.where((word) => wordIdsToReview.contains(word.id)).toList();
});

// Provider for new/unstudied words
final newWordsProvider = FutureProvider<List<Word>>((ref) async {
  final allWords = await ref.watch(allWordsProvider.future);
  final learningProgress = ref.watch(learningProgressProvider);
  final studiedWordIds = learningProgress.keys.toSet();

  // 过滤出未学习的单词
  return allWords.where((word) => !studiedWordIds.contains(word.id)).toList();
});
