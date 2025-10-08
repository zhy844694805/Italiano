import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/quiz_provider.dart';
import '../../shared/models/quiz.dart';
import 'quiz_screen.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final todaysChallengeAsync = ref.watch(todaysChallengeProvider);
    final wrongCountAsync = ref.watch(wrongQuestionsCountProvider);
    final quizStatsAsync = ref.watch(quizStatisticsProvider);
    final challengeStreakAsync = ref.watch(challengeStreakProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('练习测验'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '测验历史',
            onPressed: () {
              // TODO: 导航到历史记录页面
            },
          ),
        ],
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

                return Card(
                  color: isCompleted
                      ? colorScheme.primaryContainer
                      : colorScheme.secondaryContainer,
                  child: InkWell(
                    onTap: isCompleted
                        ? null
                        : () => _startDailyChallenge(context, ref),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isCompleted ? Icons.check_circle : Icons.today,
                              size: 40,
                              color: isCompleted ? Colors.green : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCompleted ? '今日挑战已完成!' : '每日挑战',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isCompleted
                                      ? '得分: ${challenge?.score ?? 0} 分'
                                      : '10道题 · 混合难度',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isCompleted
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                if (!isCompleted)
                                  challengeStreakAsync.when(
                                    data: (streak) => streak > 0
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.local_fire_department,
                                                  size: 16,
                                                  color: Colors.deepOrange,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '连续 $streak 天',
                                                  style: theme.textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                    loading: () => const SizedBox(),
                                    error: (_, __) => const SizedBox(),
                                  ),
                              ],
                            ),
                          ),
                          if (!isCompleted)
                            Icon(
                              Icons.arrow_forward_ios,
                              color: colorScheme.onSecondaryContainer,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            Text(
              '测验模式',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 综合测验卡片
            _QuizModeCard(
              icon: Icons.quiz,
              title: '综合测验',
              description: '词汇+语法混合练习',
              color: colorScheme.primary,
              onTap: () => _showDifficultyDialog(
                context,
                ref,
                QuizMode.comprehensive,
              ),
            ),

            const SizedBox(height: 12),

            // 错题集卡片
            wrongCountAsync.when(
              data: (count) => _QuizModeCard(
                icon: Icons.error_outline,
                title: '错题集',
                description: count > 0 ? '$count 道错题待复习' : '暂无错题',
                color: Colors.red,
                badge: count > 0 ? '$count' : null,
                onTap: count > 0
                    ? () => _startWrongQuestionsQuiz(context, ref)
                    : null,
              ),
              loading: () => _QuizModeCard(
                icon: Icons.error_outline,
                title: '错题集',
                description: '加载中...',
                color: Colors.red,
              ),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // 统计信息
            quizStatsAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '我的统计',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: '完成测验',
                                value: '${stats['totalQuizzes']}',
                                icon: Icons.check_circle,
                                color: colorScheme.primary,
                              ),
                              _StatItem(
                                label: '平均分',
                                value: '${stats['avgScore'].toStringAsFixed(0)}',
                                icon: Icons.score,
                                color: colorScheme.secondary,
                              ),
                              _StatItem(
                                label: '最高分',
                                value: '${stats['maxScore']}',
                                icon: Icons.star,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '总正确率',
                                style: theme.textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                '${(stats['accuracy'] * 100).toStringAsFixed(1)}%',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: stats['accuracy'],
                              minHeight: 10,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
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

  void _showDifficultyDialog(
    BuildContext context,
    WidgetRef ref,
    QuizMode mode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择难度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sentiment_satisfied, color: Colors.green),
              title: const Text('简单'),
              subtitle: const Text('A1-A2 级别'),
              onTap: () {
                Navigator.pop(context);
                _startComprehensiveQuiz(context, ref, QuizDifficulty.easy);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_neutral, color: Colors.orange),
              title: const Text('中等'),
              subtitle: const Text('B1-B2 级别'),
              onTap: () {
                Navigator.pop(context);
                _startComprehensiveQuiz(context, ref, QuizDifficulty.medium);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_very_dissatisfied,
                  color: Colors.red),
              title: const Text('困难'),
              subtitle: const Text('C1-C2 级别'),
              onTap: () {
                Navigator.pop(context);
                _startComprehensiveQuiz(context, ref, QuizDifficulty.hard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle, color: Colors.purple),
              title: const Text('混合'),
              subtitle: const Text('所有级别'),
              onTap: () {
                Navigator.pop(context);
                _startComprehensiveQuiz(context, ref, QuizDifficulty.mixed);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startComprehensiveQuiz(
    BuildContext context,
    WidgetRef ref,
    QuizDifficulty difficulty,
  ) async {
    final questions =
        await ref.read(comprehensiveQuizProvider(difficulty).future);

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

class _QuizModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? badge;
  final VoidCallback? onTap;

  const _QuizModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
