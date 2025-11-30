import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_guide.dart';
import '../../core/database/learning_guide_progress_repository.dart';
import '../../core/database/learning_statistics_repository.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// 学习路径指导服务
class LearningGuideService {
  static LearningGuideService? _instance;
  static LearningGuideService get instance => _instance ??= LearningGuideService._();

  LearningGuideService._();

  List<LearningGuide>? _guides;
  bool _isLoading = false;
  String? _error;

  List<LearningGuide>? get guides => _guides;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载学习路径数据
  Future<void> loadGuides() async {
    if (_guides != null && _guides!.isNotEmpty) return;

    _isLoading = true;
    _error = null;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/learning_guides.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _guides = jsonList.map((json) => LearningGuide.fromJson(json)).toList();
    } catch (e) {
      _error = '加载学习路径失败: $e';
    } finally {
      _isLoading = false;
    }
  }

  /// 根据级别获取学习路径
  List<LearningGuide> getGuidesByLevel(String level) {
    if (_guides == null) return [];
    return _guides!.where((guide) => guide.level == level).toList();
  }

  /// 获取核心学习路径
  List<LearningGuide> getEssentialGuides() {
    if (_guides == null) return [];
    return _guides!.where((guide) => guide.isEssential).toList();
  }

  /// 根据ID获取学习路径
  LearningGuide? getGuideById(String id) {
    if (_guides == null) return null;
    try {
      return _guides!.firstWhere((guide) => guide.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取当前活跃的学习路径
  LearningGuide? getCurrentActiveGuide(List<LearningGuideProgress> progressList) {
    if (progressList.isEmpty) return getEssentialGuides().firstOrNull;

    // 找到最近活跃且未完成的学习路径
    final activeProgress = progressList.where((p) => !p.isCompleted).toList();
    if (activeProgress.isEmpty) {
      return getEssentialGuides().firstOrNull;
    }

    // 找到最新活跃的进度
    activeProgress.sort((a, b) => b.lastActiveDate?.compareTo(a.lastActiveDate ?? DateTime.now()) ?? 0);
    final latestProgress = activeProgress.first;
    return getGuideById(latestProgress.guideId);
  }

  /// 获取每日任务
  DailyTask? getDailyTask(String guideId, int day) {
    final guide = getGuideById(guideId);
    if (guide == null) return null;
    try {
      return guide.tasks.firstWhere((task) => task.day == day);
    } catch (e) {
      return null;
    }
  }

  /// 获取当前应该学习的任务
  DailyTask? getCurrentTask(String guideId, int currentDay) {
    final guide = getGuideById(guideId);
    if (guide == null) return null;

    // 查找当前天数或最近未完成天数的任务
    for (int i = currentDay; i <= guide.totalDays; i++) {
      final task = getDailyTask(guideId, i);
      if (task != null && !task.isOptional) {
        return task;
      }
    }

    return null;
  }

  /// 检查任务是否完成
  bool isTaskCompleted(DailyTask task, List<String> completedTasks) {
    return task.items.every((item) => completedTasks.contains('${task.day}_${item.id}'));
  }

  /// 检查里程碑是否达成
  bool isMilestoneAchieved(LearningMilestone milestone, int currentDay, int completedWords, int completedGrammar) {
    if (currentDay < milestone.day) return false;

    // 这里可以添加更复杂的达成条件检查
    switch (milestone.type) {
      case MilestoneType.vocabularyMilestone:
        return completedWords >= 50; // 简化检查
      case MilestoneType.grammarMilestone:
        return completedGrammar >= 4;
      case MilestoneType.comprehensiveMilestone:
        return currentDay >= 30;
      default:
        return currentDay >= milestone.day;
    }
  }

  /// 获取学习建议
  List<String> getLearningSuggestion(String guideId, int currentDay, LearningGuideProgress? progress) {
    final suggestions = <String>[];
    final guide = getGuideById(guideId);
    if (guide == null) return suggestions;

    // 基于进度的建议
    if (progress != null) {
      final consecutiveDays = progress.consecutiveDays;

      if (consecutiveDays >= 7) {
        suggestions.add('🎉 连续学习${consecutiveDays}天！保持这个习惯，A1水平就在前方！');
      } else if (consecutiveDays >= 3) {
        suggestions.add('💪 连续学习${consecutiveDays}天，继续加油！');
      } else {
        suggestions.add('⚠️ 坚持每天学习是成功的关键，尽量保持连续性。');
      }

      // 基于完成度的建议
      if (progress.progressPercentage >= 0.8) {
        suggestions.add('🎯 进度超过80%，准备进行A1测试吧！');
      } else if (progress.progressPercentage >= 0.5) {
        suggestions.add('📈 进度良好，继续保持每天学习的节奏。');
      } else if (progress.progressPercentage < 0.3) {
        suggestions.add('📅 进度较慢，建议每天多花10-15分钟学习。');
      }
    }

    // 基于当前天数的建议
    if (currentDay <= 7) {
      suggestions.add('🌟 基础阶段：重点掌握发音和基础词汇，建立语感。');
    } else if (currentDay <= 14) {
      suggestions.add('🌟 发展阶段：开始学习基础语法，扩充词汇量。');
    } else if (currentDay <= 21) {
      suggestions.add('🌟 进阶阶段：学习现在时，练习基本对话。');
    } else if (currentDay <= 30) {
      suggestions.add('🌟 巩固阶段：全面复习，准备A1测试。');
    }

    return suggestions;
  }

  /// 获取今日学习计划
  Map<String, dynamic> getTodayLearningPlan(String guideId, int currentDay, List<String> completedTasks) {
    final task = getCurrentTask(guideId, currentDay);
    if (task == null) {
      return {
        'hasTask': false,
        'message': '恭喜！你已经完成了所有学习任务！',
        'suggestion': '可以开始复习或进行A1测试。'
      };
    }

    final isCompleted = isTaskCompleted(task, completedTasks);
    final guide = getGuideById(guideId);

    return {
      'hasTask': true,
      'task': task,
      'guide': guide,
      'isCompleted': isCompleted,
      'progress': '${currentDay}/${guide?.totalDays ?? 30}',
      'suggestions': getLearningSuggestion(guideId, currentDay, null),
      'estimatedMinutes': task.estimatedMinutes,
    };
  }

  /// 计算学习统计
  Map<String, dynamic> calculateLearningStatistics(List<LearningGuideProgress> allProgress) {
    if (allProgress.isEmpty) {
      return {
        'totalGuidesStarted': 0,
        'activeGuides': 0,
        'completedGuides': 0,
        'totalDaysStudied': 0,
        'totalMinutesSpent': 0,
        'consecutiveDays': 0,
        'averageMinutesPerDay': 0,
      };
    }

    final completedGuides = allProgress.where((p) => p.isCompleted).length;
    final totalDaysStudied = allProgress
        .map((p) => p.completedDays.length)
        .reduce((a, b) => a + b, 0);
    final totalMinutesSpent = allProgress
        .map((p) => p.totalMinutesSpent)
        .reduce((a, b) => a + b, 0);

    // 计算连续学习天数（简化版）
    final sortedDates = allProgress
        .map((p) => p.lastActiveDate ?? p.startedAt)
        .toList()..sort();

    int consecutiveDays = 0;
    DateTime? lastDate;

    for (final date in sortedDates.reversed) {
      if (lastDate == null) {
        lastDate = date;
        consecutiveDays = 1;
      } else {
        final difference = lastDate!.difference(date).inDays;
        if (difference == 1) {
          consecutiveDays++;
          lastDate = date;
        } else {
          break;
        }
      }
    }

    return {
      'totalGuidesStarted': allProgress.length,
      'activeGuides': allProgress.where((p) => !p.isCompleted).length,
      'completedGuides': completedGuides,
      'totalDaysStudied': totalDaysStudied,
      'totalMinutesSpent': totalMinutesSpent,
      'consecutiveDays': consecutiveDays,
      'averageMinutesPerDay': totalDaysStudied > 0
          ? (totalMinutesSpent / totalDaysStudied).round()
          : 0,
      'totalHoursSpent': (totalMinutesSpent / 60).toStringAsFixed(1),
    };
  }

  /// 生成学习日历
  Map<int, Map<String, dynamic>> generateLearningCalendar(String guideId, DateTime month) {
    final calendar = <int, Map<String, dynamic>>{};
    final guide = getGuideById(guideId);
    if (guide == null) return calendar;

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(month.year, month.month, day);
      final dayKey = currentDate.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24); // 简化的天键

      final task = getDailyTask(guideId, day);

      calendar[day] = {
        'date': currentDate,
        'hasTask': task != null,
        'task': task,
        'isFuture': currentDate.isAfter(DateTime.now()),
        'isPast': currentDate.isBefore(DateTime.now().subtract(const Duration(days: 1))),
        'dayOfWeek': currentDate.weekday,
      };
    }

    return calendar;
  }

  /// 获取推荐内容
  Map<String, dynamic> getRecommendedContent(String guideId, int currentDay) {
    final recommendations = {
      'vocabulary': <String>[],
      'grammar': <String>[],
      'listening': <String>[],
      'speaking': <String>[],
      'reading': <String>[],
    };

    final guide = getGuideById(guideId);
    if (guide == null) return recommendations;

    // 基于当前天数和难度推荐内容
    if (currentDay <= 7) {
      // 第一周：基础内容
      recommendations['vocabulary'] = ['greetings', 'numbers_1_10', 'family_members'];
      recommendations['grammar'] = ['present_tense', 'articles', 'pronouns'];
      recommendations['listening'] = ['basic_greetings', 'number_dictation'];
      recommendations['speaking'] = ['hello_practice', 'name_presentation'];
    } else if (currentDay <= 14) {
      // 第二周：扩展内容
      recommendations['vocabulary'] = ['colors', 'body_parts', 'food_drinks'];
      recommendations['grammar'] = ['noun_gender', 'prepositions', 'basic_sentences'];
      recommendations['listening'] = ['short_dialogues', 'word_recognition'];
      recommendations['speaking'] = ['daily_routines', 'restaurant_practice'];
    } else if (currentDay <= 21) {
      // 第三周：进阶内容
      recommendations['vocabulary'] = ['daily_activities', 'places', 'transport'];
      recommendations['grammar'] = ['past_tense', 'adjectives', 'questions'];
      recommendations['listening'] = ['question_answer', 'sentence_completion'];
      recommendations['speaking'] = ['conversation_practice', 'opinion_expressions'];
    } else {
      // 第四周：巩固内容
      recommendations['vocabulary'] = ['weather', 'time_expressions', 'comprehensive_review'];
      recommendations['grammar'] = ['all_grammar_review', 'complex_sentences'];
      recommendations['listening'] = ['all_listening_review'];
      recommendations['speaking'] = ['free_conversation', 'pronunciation_polish'];
    }

    return recommendations;
  }
}

/// 学习路径指导Provider
final learningGuideServiceProvider = Provider<LearningGuideService>((ref) {
  return LearningGuideService.instance;
});

/// 所有学习路径Provider
final allLearningGuidesProvider = FutureProvider<List<LearningGuide>>((ref) async {
  final service = ref.read(learningGuideServiceProvider);
  await service.loadGuides();
  return service.guides ?? [];
});

/// A1级别学习路径Provider
final a1LearningGuidesProvider = Provider<List<LearningGuide>>((ref) {
  final service = ref.watch(learningGuideServiceProvider);
  return service.getGuidesByLevel('A1');
});

/// A2级别学习路径Provider
final a2LearningGuidesProvider = Provider<List<LearningGuide>>((ref) {
  final service = ref.watch(learningGuideServiceProvider);
  return service.getGuidesByLevel('A2');
});

/// 核心学习路径Provider
final essentialLearningGuidesProvider = Provider<List<LearningGuide>>((ref) {
  final service = ref.watch(learningGuideServiceProvider);
  return service.getEssentialGuides();
});

/// 当前活跃学习路径Provider
final currentActiveGuideProvider = Provider<LearningGuide?>((ref) {
  final progress = ref.watch(learningGuideProgressProvider);
  final service = ref.watch(learningGuideServiceProvider);
  return service.getCurrentActiveGuide(progress);
});

/// 今日学习计划Provider
final todayLearningPlanProvider = Provider<Map<String, dynamic>>((ref) {
  final activeGuide = ref.watch(currentActiveGuideProvider);
  final progress = ref.watch(learningGuideProgressProvider);

  if (activeGuide == null) {
    return {'hasTask': false, 'message': '选择一个学习路径开始吧！'};
  }

  final currentProgress = progress.firstWhere(
    (p) => p.guideId == activeGuide!.id,
    orElse: () => LearningGuideProgress(
      guideId: activeGuide!.id,
      startedAt: DateTime.now(),
      currentDay: 1,
      completedDays: [],
      completedTasks: [],
      achievedMilestones: [],
      totalMinutesSpent: 0,
      isCompleted: false,
    ),
  );

  final service = ref.watch(learningGuideServiceProvider);
  final completedTasks = currentProgress.completedTasks;

  return service.getTodayLearningPlan(
    activeGuide!.id,
    currentProgress.currentDay,
    completedTasks,
  );
});

/// 学习进度Notifier
class LearningGuideProgressNotifier extends StateNotifier<List<LearningGuideProgress>> {
  final LearningGuideProgressRepository _repository;
  final LearningStatisticsRepository _statsRepository;

  LearningGuideProgressNotifier(this._repository, this._statsRepository)
      : super([]) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await _repository.getAllGuideProgress();
      state = progress;
    } catch (e) {
      // 错误处理
    }
  }

  /// 开始学习路径
  Future<void> startGuide(String guideId) async {
    try {
      final progress = LearningGuideProgress(
        guideId: guideId,
        startedAt: DateTime.now(),
        currentDay: 1,
        completedDays: [],
        completedTasks: [],
        achievedMilestones: [],
        totalMinutesSpent: 0,
        isCompleted: false,
      );

      await _repository.addGuideProgress(progress);

      // 更新学习统计
      final today = DateTime.now();
      await _statsRepository.addStudyTime(today, 0); // 记录学习日

      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 更新任务完成状态
  Future<void> updateTaskProgress(
    String guideId,
    int day,
    String taskId,
    int minutesSpent,
  ) async {
    try {
      final currentProgress = state.firstWhere(
        (p) => p.guideId == guideId,
        orElse: () => LearningGuideProgress(
          guideId: guideId,
          startedAt: DateTime.now(),
          currentDay: 1,
          completedDays: [],
          completedTasks: [],
          achievedMilestones: [],
          totalMinutesSpent: 0,
          isCompleted: false,
        ),
      );

      final taskKey = '${day}_$taskId';
      final newCompletedTasks = [...currentProgress.completedTasks];
      if (!newCompletedTasks.contains(taskKey)) {
        newCompletedTasks.add(taskKey);
      }

      final newCompletedDays = [...currentProgress.completedDays];
      final dayKey = day.toString();
      if (!newCompletedDays.contains(dayKey)) {
        newCompletedDays.add(dayKey);
      }

      final updatedProgress = currentProgress.copyWith(
        lastActiveDate: DateTime.now(),
        completedDays: newCompletedDays,
        completedTasks: newCompletedTasks,
        totalMinutesSpent: currentProgress.totalMinutesSpent + minutesSpent,
      );

      await _repository.updateGuideProgress(updatedProgress);

      // 更新学习统计
      final today = DateTime.now();
      await _statsRepository.addStudyTime(today, minutesSpent);

      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String guideId) async {
    try {
      await _repository.toggleFavorite(guideId);
      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 获取指定学习路径的进度
  LearningGuideProgress? getProgress(String guideId) {
    try {
      return state.firstWhere((p) => p.guideId == guideId);
    } catch (e) {
      return null;
    }
  }

  /// 清除所有进度
  Future<void> clearAllProgress() async {
    try {
      await _repository.clearAllGuideProgress();
      state = [];
    } catch (e) {
      // 错误处理
    }
  }
}

/// 学习进度Provider
final learningGuideProgressProvider = StateNotifierProvider<LearningGuideProgressNotifier, List<LearningGuideProgress>>((ref) {
  final repository = ref.read(learningGuideProgressRepositoryProvider);
  final statsRepository = ref.read(learningStatisticsRepositoryProvider);
  return LearningGuideProgressNotifier(repository, statsRepository);
});

/// 学习统计Provider
final learningStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.read(learningGuideServiceProvider);
  final progress = ref.watch(learningGuideProgressProvider);
  return service.calculateLearningStatistics(progress);
});