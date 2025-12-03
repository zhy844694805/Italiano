import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/statistics_provider.dart';
import '../../core/theme/openai_theme.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);
    final vocabularyStatsAsync = ref.watch(vocabularyStatsProvider);
    final grammarStatsAsync = ref.watch(grammarStatsProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('学习成就'),
      ),
      body: statisticsAsync.when(
        data: (stats) {
          final vocabStats = vocabularyStatsAsync.valueOrNull ?? {};
          final grammarStats = grammarStatsAsync.valueOrNull ?? {};

          final achievements = _buildAchievements(
            stats.studyStreak,
            stats.totalStudyDays,
            stats.totalWordsLearned,
            stats.totalGrammarStudied,
            vocabStats['masteredWords'] ?? 0,
            grammarStats['completedCount'] ?? 0,
          );

          final unlockedCount = achievements.where((a) => a.isUnlocked).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总览卡片
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: OpenAITheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: OpenAITheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 28,
                          color: OpenAITheme.openaiGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$unlockedCount / ${achievements.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: OpenAITheme.textPrimary,
                            ),
                          ),
                          const Text(
                            '已解锁成就',
                            style: TextStyle(
                              fontSize: 14,
                              color: OpenAITheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 成就列表
                const Text(
                  '全部成就',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                ...achievements.map((achievement) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AchievementCard(achievement: achievement),
                )),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
        ),
        error: (_, __) => const Center(
          child: Text('加载失败'),
        ),
      ),
    );
  }

  List<_Achievement> _buildAchievements(
    int streak,
    int totalDays,
    int wordsLearned,
    int grammarStudied,
    int wordsMastered,
    int grammarCompleted,
  ) {
    return [
      // 学习天数成就
      _Achievement(
        icon: Icons.calendar_today,
        title: '初学者',
        description: '完成第一天学习',
        progress: totalDays,
        target: 1,
        color: OpenAITheme.openaiGreen,
      ),
      _Achievement(
        icon: Icons.calendar_month,
        title: '坚持一周',
        description: '累计学习7天',
        progress: totalDays,
        target: 7,
        color: OpenAITheme.openaiGreen,
      ),
      _Achievement(
        icon: Icons.event_available,
        title: '学习达人',
        description: '累计学习30天',
        progress: totalDays,
        target: 30,
        color: OpenAITheme.openaiGreen,
      ),

      // 连续学习成就
      _Achievement(
        icon: Icons.local_fire_department,
        title: '三天热情',
        description: '连续学习3天',
        progress: streak,
        target: 3,
        color: OpenAITheme.warning,
      ),
      _Achievement(
        icon: Icons.whatshot,
        title: '一周坚持',
        description: '连续学习7天',
        progress: streak,
        target: 7,
        color: OpenAITheme.warning,
      ),
      _Achievement(
        icon: Icons.rocket_launch,
        title: '习惯养成',
        description: '连续学习30天',
        progress: streak,
        target: 30,
        color: OpenAITheme.warning,
      ),

      // 词汇成就
      _Achievement(
        icon: Icons.abc,
        title: '词汇入门',
        description: '学习10个单词',
        progress: wordsLearned,
        target: 10,
        color: OpenAITheme.info,
      ),
      _Achievement(
        icon: Icons.translate,
        title: '词汇小能手',
        description: '学习50个单词',
        progress: wordsLearned,
        target: 50,
        color: OpenAITheme.info,
      ),
      _Achievement(
        icon: Icons.auto_stories,
        title: '词汇达人',
        description: '学习200个单词',
        progress: wordsLearned,
        target: 200,
        color: OpenAITheme.info,
      ),
      _Achievement(
        icon: Icons.workspace_premium,
        title: '词汇大师',
        description: '学习500个单词',
        progress: wordsLearned,
        target: 500,
        color: OpenAITheme.info,
      ),

      // 掌握成就
      _Achievement(
        icon: Icons.check_circle_outline,
        title: '初步掌握',
        description: '掌握10个单词',
        progress: wordsMastered,
        target: 10,
        color: const Color(0xFF8B5CF6),
      ),
      _Achievement(
        icon: Icons.verified,
        title: '牢固记忆',
        description: '掌握50个单词',
        progress: wordsMastered,
        target: 50,
        color: const Color(0xFF8B5CF6),
      ),
      _Achievement(
        icon: Icons.military_tech,
        title: '记忆大师',
        description: '掌握200个单词',
        progress: wordsMastered,
        target: 200,
        color: const Color(0xFF8B5CF6),
      ),

      // 语法成就
      _Achievement(
        icon: Icons.school_outlined,
        title: '语法入门',
        description: '学习第一个语法点',
        progress: grammarStudied,
        target: 1,
        color: const Color(0xFFEC4899),
      ),
      _Achievement(
        icon: Icons.menu_book,
        title: '语法基础',
        description: '完成5个语法课程',
        progress: grammarCompleted,
        target: 5,
        color: const Color(0xFFEC4899),
      ),
      _Achievement(
        icon: Icons.history_edu,
        title: '语法达人',
        description: '完成全部14个语法课程',
        progress: grammarCompleted,
        target: 14,
        color: const Color(0xFFEC4899),
      ),
    ];
  }
}

// 成就数据类
class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final int progress;
  final int target;
  final Color color;

  _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.color,
  });

  bool get isUnlocked => progress >= target;
  double get progressPercent => (progress / target).clamp(0.0, 1.0);
}

// 成就卡片
class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? achievement.color : OpenAITheme.borderLight,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? achievement.color.withValues(alpha: 0.1)
                  : OpenAITheme.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement.icon,
              size: 26,
              color: isUnlocked ? achievement.color : OpenAITheme.textTertiary,
            ),
          ),
          const SizedBox(width: 14),

          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? OpenAITheme.textPrimary
                            : OpenAITheme.textTertiary,
                      ),
                    ),
                    if (isUnlocked) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: achievement.color,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isUnlocked
                        ? OpenAITheme.textSecondary
                        : OpenAITheme.textTertiary,
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: OpenAITheme.gray100,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: achievement.progressPercent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: achievement.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${achievement.progress}/${achievement.target}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: OpenAITheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
