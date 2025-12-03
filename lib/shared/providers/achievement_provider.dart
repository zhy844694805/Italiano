import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'statistics_provider.dart';

// 成就定义
class Achievement {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final int target;
  final Color color;
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.target,
    required this.color,
    required this.category,
  });
}

enum AchievementCategory {
  studyDays,    // 学习天数
  streak,       // 连续学习
  vocabulary,   // 词汇学习
  mastery,      // 词汇掌握
  grammar,      // 语法学习
}

// 所有成就定义
class AchievementDefinitions {
  static const Color green = Color(0xFF10A37F);
  static const Color orange = Color(0xFFF59E0B);
  static const Color blue = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);

  static final List<Achievement> all = [
    // 学习天数成就
    Achievement(
      id: 'study_days_1',
      icon: Icons.calendar_today,
      title: '初学者',
      description: '完成第一天学习',
      target: 1,
      color: green,
      category: AchievementCategory.studyDays,
    ),
    Achievement(
      id: 'study_days_7',
      icon: Icons.calendar_month,
      title: '坚持一周',
      description: '累计学习7天',
      target: 7,
      color: green,
      category: AchievementCategory.studyDays,
    ),
    Achievement(
      id: 'study_days_30',
      icon: Icons.event_available,
      title: '学习达人',
      description: '累计学习30天',
      target: 30,
      color: green,
      category: AchievementCategory.studyDays,
    ),

    // 连续学习成就
    Achievement(
      id: 'streak_3',
      icon: Icons.local_fire_department,
      title: '三天热情',
      description: '连续学习3天',
      target: 3,
      color: orange,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'streak_7',
      icon: Icons.whatshot,
      title: '一周坚持',
      description: '连续学习7天',
      target: 7,
      color: orange,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'streak_30',
      icon: Icons.rocket_launch,
      title: '习惯养成',
      description: '连续学习30天',
      target: 30,
      color: orange,
      category: AchievementCategory.streak,
    ),

    // 词汇成就
    Achievement(
      id: 'words_10',
      icon: Icons.abc,
      title: '词汇入门',
      description: '学习10个单词',
      target: 10,
      color: blue,
      category: AchievementCategory.vocabulary,
    ),
    Achievement(
      id: 'words_50',
      icon: Icons.translate,
      title: '词汇小能手',
      description: '学习50个单词',
      target: 50,
      color: blue,
      category: AchievementCategory.vocabulary,
    ),
    Achievement(
      id: 'words_200',
      icon: Icons.auto_stories,
      title: '词汇达人',
      description: '学习200个单词',
      target: 200,
      color: blue,
      category: AchievementCategory.vocabulary,
    ),
    Achievement(
      id: 'words_500',
      icon: Icons.workspace_premium,
      title: '词汇大师',
      description: '学习500个单词',
      target: 500,
      color: blue,
      category: AchievementCategory.vocabulary,
    ),

    // 掌握成就
    Achievement(
      id: 'mastery_10',
      icon: Icons.check_circle_outline,
      title: '初步掌握',
      description: '掌握10个单词',
      target: 10,
      color: purple,
      category: AchievementCategory.mastery,
    ),
    Achievement(
      id: 'mastery_50',
      icon: Icons.verified,
      title: '牢固记忆',
      description: '掌握50个单词',
      target: 50,
      color: purple,
      category: AchievementCategory.mastery,
    ),
    Achievement(
      id: 'mastery_200',
      icon: Icons.military_tech,
      title: '记忆大师',
      description: '掌握200个单词',
      target: 200,
      color: purple,
      category: AchievementCategory.mastery,
    ),

    // 语法成就
    Achievement(
      id: 'grammar_1',
      icon: Icons.school_outlined,
      title: '语法入门',
      description: '学习第一个语法点',
      target: 1,
      color: pink,
      category: AchievementCategory.grammar,
    ),
    Achievement(
      id: 'grammar_5',
      icon: Icons.menu_book,
      title: '语法基础',
      description: '完成5个语法课程',
      target: 5,
      color: pink,
      category: AchievementCategory.grammar,
    ),
    Achievement(
      id: 'grammar_14',
      icon: Icons.history_edu,
      title: '语法达人',
      description: '完成全部14个语法课程',
      target: 14,
      color: pink,
      category: AchievementCategory.grammar,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

// 成就状态
class AchievementState {
  final Set<String> unlockedIds;
  final Set<String> notifiedIds; // 已经通知过的成就
  final Achievement? newlyUnlocked; // 新解锁的成就（用于显示弹窗）

  const AchievementState({
    this.unlockedIds = const {},
    this.notifiedIds = const {},
    this.newlyUnlocked,
  });

  AchievementState copyWith({
    Set<String>? unlockedIds,
    Set<String>? notifiedIds,
    Achievement? newlyUnlocked,
    bool clearNewlyUnlocked = false,
  }) {
    return AchievementState(
      unlockedIds: unlockedIds ?? this.unlockedIds,
      notifiedIds: notifiedIds ?? this.notifiedIds,
      newlyUnlocked: clearNewlyUnlocked ? null : (newlyUnlocked ?? this.newlyUnlocked),
    );
  }
}

// 成就状态管理
class AchievementNotifier extends StateNotifier<AchievementState> {
  AchievementNotifier() : super(const AchievementState()) {
    _loadUnlockedAchievements();
  }

  static const String _storageKey = 'unlocked_achievements';
  static const String _notifiedKey = 'notified_achievements';

  Future<void> _loadUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedList = prefs.getStringList(_storageKey) ?? [];
    final notifiedList = prefs.getStringList(_notifiedKey) ?? [];
    state = state.copyWith(
      unlockedIds: unlockedList.toSet(),
      notifiedIds: notifiedList.toSet(),
    );
  }

  Future<void> _saveUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, state.unlockedIds.toList());
    await prefs.setStringList(_notifiedKey, state.notifiedIds.toList());
  }

  // 检查并解锁成就
  Future<Achievement?> checkAndUnlock({
    required int totalDays,
    required int streak,
    required int wordsLearned,
    required int wordsMastered,
    required int grammarCompleted,
  }) async {
    Achievement? newUnlock;

    for (final achievement in AchievementDefinitions.all) {
      if (state.unlockedIds.contains(achievement.id)) continue;

      int progress = 0;
      switch (achievement.category) {
        case AchievementCategory.studyDays:
          progress = totalDays;
          break;
        case AchievementCategory.streak:
          progress = streak;
          break;
        case AchievementCategory.vocabulary:
          progress = wordsLearned;
          break;
        case AchievementCategory.mastery:
          progress = wordsMastered;
          break;
        case AchievementCategory.grammar:
          progress = grammarCompleted;
          break;
      }

      if (progress >= achievement.target) {
        // 解锁新成就
        final newUnlockedIds = {...state.unlockedIds, achievement.id};

        // 如果还没通知过，设置为新解锁
        if (!state.notifiedIds.contains(achievement.id)) {
          newUnlock = achievement;
          final newNotifiedIds = {...state.notifiedIds, achievement.id};
          state = state.copyWith(
            unlockedIds: newUnlockedIds,
            notifiedIds: newNotifiedIds,
            newlyUnlocked: achievement,
          );
        } else {
          state = state.copyWith(unlockedIds: newUnlockedIds);
        }

        await _saveUnlockedAchievements();

        // 只返回第一个新解锁的成就
        if (newUnlock != null) break;
      }
    }

    return newUnlock;
  }

  // 清除新解锁状态（弹窗显示后调用）
  void clearNewlyUnlocked() {
    state = state.copyWith(clearNewlyUnlocked: true);
  }

  // 获取成就进度
  int getProgress(Achievement achievement, {
    required int totalDays,
    required int streak,
    required int wordsLearned,
    required int wordsMastered,
    required int grammarCompleted,
  }) {
    switch (achievement.category) {
      case AchievementCategory.studyDays:
        return totalDays;
      case AchievementCategory.streak:
        return streak;
      case AchievementCategory.vocabulary:
        return wordsLearned;
      case AchievementCategory.mastery:
        return wordsMastered;
      case AchievementCategory.grammar:
        return grammarCompleted;
    }
  }

  bool isUnlocked(String achievementId) {
    return state.unlockedIds.contains(achievementId);
  }
}

// Provider
final achievementProvider = StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  return AchievementNotifier();
});

// 辅助方法：检查成就（在学习完成后调用）
Future<Achievement?> checkAchievements(WidgetRef ref) async {
  final stats = await ref.read(statisticsProvider.future);
  final vocabStats = await ref.read(vocabularyStatsProvider.future);
  final grammarStats = await ref.read(grammarStatsProvider.future);

  return ref.read(achievementProvider.notifier).checkAndUnlock(
    totalDays: stats.totalStudyDays,
    streak: stats.studyStreak,
    wordsLearned: stats.totalWordsLearned,
    wordsMastered: vocabStats['masteredWords'] ?? 0,
    grammarCompleted: grammarStats['completedCount'] ?? 0,
  );
}
