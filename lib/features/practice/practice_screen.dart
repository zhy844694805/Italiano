import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/quiz_provider.dart';
import '../../shared/models/quiz.dart';
import '../../core/theme/openai_theme.dart';
import 'quiz_screen.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysChallengeAsync = ref.watch(todaysChallengeProvider);
    final wrongCountAsync = ref.watch(wrongQuestionsCountProvider);
    final quizStatsAsync = ref.watch(quizStatisticsProvider);
    final challengeStreakAsync = ref.watch(challengeStreakProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('练习测验'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 每日挑战卡片
            todaysChallengeAsync.when(
              data: (challenge) {
                final isCompleted = challenge?.completed ?? false;
                return _DailyChallengeCard(
                  isCompleted: isCompleted,
                  score: challenge?.score ?? 0,
                  streak: challengeStreakAsync.valueOrNull ?? 0,
                  onTap: isCompleted ? null : () => _startDailyChallenge(context, ref),
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: OpenAITheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OpenAITheme.borderLight),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
                ),
              ),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 28),

            // 测验模式标题
            const Text(
              '测验模式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '选择一种模式开始练习',
              style: TextStyle(
                fontSize: 13,
                color: OpenAITheme.textTertiary,
              ),
            ),
            const SizedBox(height: 16),

            // 综合测验卡片
            _QuizModeCard(
              icon: Icons.quiz_outlined,
              title: '综合测验',
              description: '词汇+语法混合练习，全面提升',
              onTap: () => _showDifficultyDialog(context, ref),
            ),

            const SizedBox(height: 12),

            // 错题集卡片
            wrongCountAsync.when(
              data: (count) => _QuizModeCard(
                icon: Icons.refresh_outlined,
                title: '错题集',
                description: count > 0 ? '$count 道错题待复习' : '暂无错题，继续保持！',
                badge: count > 0 ? count : null,
                onTap: count > 0 ? () => _startWrongQuestionsQuiz(context, ref) : null,
                disabled: count == 0,
              ),
              loading: () => _QuizModeCard(
                icon: Icons.refresh_outlined,
                title: '错题集',
                description: '加载中...',
                disabled: true,
              ),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 28),

            // 我的统计标题
            const Text(
              '我的统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // 统计信息
            quizStatsAsync.when(
              data: (stats) => _StatisticsCard(stats: stats),
              loading: () => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: OpenAITheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OpenAITheme.borderLight),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
                ),
              ),
              error: (_, __) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: OpenAITheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OpenAITheme.borderLight),
                ),
                child: const Center(
                  child: Text(
                    '暂无统计数据',
                    style: TextStyle(color: OpenAITheme.textTertiary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startDailyChallenge(BuildContext context, WidgetRef ref) async {
    final questions = await ref.read(dailyChallengeQuestionsProvider.future);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          mode: QuizMode.daily,
          difficulty: QuizDifficulty.mixed,
          questions: questions,
        ),
      ),
    );
  }

  void _startWrongQuestionsQuiz(BuildContext context, WidgetRef ref) async {
    final questions = await ref.read(wrongQuestionsQuizProvider.future);

    if (questions.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('错题集为空')),
      );
      return;
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          mode: QuizMode.wrongQuestions,
          difficulty: QuizDifficulty.mixed,
          questions: questions,
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择难度',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '根据你的水平选择合适的难度',
                style: TextStyle(
                  fontSize: 13,
                  color: OpenAITheme.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              _DifficultyOption(
                title: '入门',
                subtitle: 'A1-A2 级别，适合初学者',
                color: OpenAITheme.openaiGreen,
                onTap: () {
                  Navigator.pop(context);
                  _startComprehensiveQuiz(context, ref, QuizDifficulty.easy);
                },
              ),
              const SizedBox(height: 10),
              _DifficultyOption(
                title: '进阶',
                subtitle: 'B1-B2 级别，适合有基础的学习者',
                color: OpenAITheme.info,
                onTap: () {
                  Navigator.pop(context);
                  _startComprehensiveQuiz(context, ref, QuizDifficulty.medium);
                },
              ),
              const SizedBox(height: 10),
              _DifficultyOption(
                title: '挑战',
                subtitle: 'C1-C2 级别，适合高级学习者',
                color: OpenAITheme.warning,
                onTap: () {
                  Navigator.pop(context);
                  _startComprehensiveQuiz(context, ref, QuizDifficulty.hard);
                },
              ),
              const SizedBox(height: 10),
              _DifficultyOption(
                title: '混合',
                subtitle: '所有级别随机出题',
                color: OpenAITheme.gray500,
                onTap: () {
                  Navigator.pop(context);
                  _startComprehensiveQuiz(context, ref, QuizDifficulty.mixed);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startComprehensiveQuiz(
    BuildContext context,
    WidgetRef ref,
    QuizDifficulty difficulty,
  ) async {
    final questions = await ref.read(comprehensiveQuizProvider(difficulty).future);

    if (questions.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该难度暂无题目')),
      );
      return;
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          mode: QuizMode.comprehensive,
          difficulty: difficulty,
          questions: questions,
        ),
      ),
    );
  }
}

// 每日挑战卡片
class _DailyChallengeCard extends StatelessWidget {
  final bool isCompleted;
  final int score;
  final int streak;
  final VoidCallback? onTap;

  const _DailyChallengeCard({
    required this.isCompleted,
    required this.score,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompleted
                ? OpenAITheme.openaiGreen.withValues(alpha: 0.08)
                : OpenAITheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted ? OpenAITheme.openaiGreen : OpenAITheme.borderLight,
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // 图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? OpenAITheme.openaiGreen.withValues(alpha: 0.15)
                      : OpenAITheme.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.today_outlined,
                  size: 28,
                  color: isCompleted ? OpenAITheme.openaiGreen : OpenAITheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),

              // 文字内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? '今日挑战已完成!' : '每日挑战',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? OpenAITheme.openaiGreen : OpenAITheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted ? '得分: $score 分' : '10道题 · 混合难度',
                      style: const TextStyle(
                        fontSize: 14,
                        color: OpenAITheme.textSecondary,
                      ),
                    ),
                    if (!isCompleted && streak > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: OpenAITheme.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '连续 $streak 天',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: OpenAITheme.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 箭头
              if (!isCompleted)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: OpenAITheme.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 测验模式卡片
class _QuizModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int? badge;
  final VoidCallback? onTap;
  final bool disabled;

  const _QuizModeCard({
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: OpenAITheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OpenAITheme.borderLight),
          ),
          child: Row(
            children: [
              // 图标
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: disabled
                          ? OpenAITheme.gray100
                          : OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: disabled ? OpenAITheme.textTertiary : OpenAITheme.openaiGreen,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: OpenAITheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 20),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: OpenAITheme.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // 文字
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: disabled ? OpenAITheme.textTertiary : OpenAITheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: disabled ? OpenAITheme.textTertiary : OpenAITheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 箭头
              if (!disabled)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: OpenAITheme.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 难度选项
class _DifficultyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: OpenAITheme.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: OpenAITheme.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: OpenAITheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OpenAITheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: OpenAITheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 统计卡片
class _StatisticsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatisticsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final accuracy = (stats['accuracy'] as double?) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        children: [
          // 统计数字
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.check_circle_outline,
                  label: '完成测验',
                  value: '${stats['totalQuizzes'] ?? 0}',
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: OpenAITheme.borderLight,
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.star_outline,
                  label: '平均分',
                  value: '${(stats['avgScore'] as double?)?.toStringAsFixed(0) ?? 0}',
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: OpenAITheme.borderLight,
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.emoji_events_outlined,
                  label: '最高分',
                  value: '${stats['maxScore'] ?? 0}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: OpenAITheme.borderLight),
          const SizedBox(height: 16),

          // 正确率
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                size: 20,
                color: OpenAITheme.openaiGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                '总正确率',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(accuracy * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.openaiGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 进度条
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: OpenAITheme.gray100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: accuracy.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: OpenAITheme.openaiGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 统计项
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: OpenAITheme.textSecondary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: OpenAITheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: OpenAITheme.textTertiary,
          ),
        ),
      ],
    );
  }
}
