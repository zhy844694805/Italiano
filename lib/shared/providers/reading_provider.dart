import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading.dart';
import '../../core/services/reading_service.dart';
import '../../core/database/database_service.dart';
import '../../core/database/reading_progress_repository.dart';

/// 阅读服务Provider
final readingServiceProvider = Provider<ReadingService>((ref) {
  return ReadingService();
});

/// 阅读进度仓储Provider
final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>((ref) {
  return ReadingProgressRepository(DatabaseService.instance);
});

/// 所有阅读文章Provider
final allReadingPassagesProvider = FutureProvider<List<ReadingPassage>>((ref) async {
  final service = ref.watch(readingServiceProvider);
  return await service.loadReadingPassages();
});

/// 按级别筛选的阅读文章Provider
final readingPassagesByLevelProvider = Provider.family<List<ReadingPassage>, String>((ref, level) {
  final passagesAsync = ref.watch(allReadingPassagesProvider);
  return passagesAsync.when(
    data: (passages) => passages.where((p) => p.level == level).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 阅读分类Provider
final readingCategoriesProvider = Provider<List<String>>((ref) {
  final passagesAsync = ref.watch(allReadingPassagesProvider);
  return passagesAsync.when(
    data: (passages) {
      final categories = passages.map((p) => p.category).toSet().toList();
      categories.sort();
      return categories;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 阅读进度管理Provider
final readingProgressProvider = StateNotifierProvider<ReadingProgressNotifier, Map<String, ReadingProgress>>((ref) {
  final repository = ref.watch(readingProgressRepositoryProvider);
  return ReadingProgressNotifier(repository);
});

/// 阅读进度状态管理器
class ReadingProgressNotifier extends StateNotifier<Map<String, ReadingProgress>> {
  final ReadingProgressRepository _repository;

  ReadingProgressNotifier(this._repository) : super({}) {
    _loadProgress();
  }

  /// 从数据库加载所有进度
  Future<void> _loadProgress() async {
    final progressList = await _repository.getAllProgress();
    state = {
      for (var progress in progressList) progress.passageId: progress
    };
  }

  /// 保存阅读结果
  Future<void> saveResult({
    required String passageId,
    required Map<String, String> userAnswers,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final progress = ReadingProgress(
      passageId: passageId,
      completedAt: DateTime.now(),
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      userAnswers: userAnswers,
      isFavorite: state[passageId]?.isFavorite ?? false,
    );

    await _repository.saveProgress(progress);
    state = {...state, passageId: progress};
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String passageId) async {
    await _repository.toggleFavorite(passageId);
    await _loadProgress(); // 重新加载以更新状态
  }

  /// 获取指定文章的进度
  ReadingProgress? getProgress(String passageId) {
    return state[passageId];
  }

  /// 获取统计信息
  Map<String, int> getStatistics() {
    int totalCompleted = state.length;
    int totalCorrect = 0;
    int totalQuestions = 0;

    for (var progress in state.values) {
      totalCorrect += progress.correctAnswers;
      totalQuestions += progress.totalQuestions;
    }

    return {
      'completed': totalCompleted,
      'correctAnswers': totalCorrect,
      'totalQuestions': totalQuestions,
    };
  }

  /// 获取已完成的文章ID列表
  List<String> getCompletedPassageIds() {
    return state.keys.toList();
  }
}
