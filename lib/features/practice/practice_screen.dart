import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/quiz_provider.dart';
import '../../shared/models/quiz.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';
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
      backgroundColor: OpenAITheme.white,
      appBar: AppBar(
        title: const Text('练习'),
        backgroundColor: OpenAITheme.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: OpenAITheme.gray600),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 每日挑战卡片
            todaysChallengeAsync.when(
              data: (challenge) {
                final isCompleted = challenge?.completed ?? false;

                return OCard(
                  onTap: isCompleted
                      ? null
                      : () => _startDailyChallenge(context, ref),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: isCompleted ? OpenAITheme.greenLight : OpenAITheme.gray50,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? OpenAITheme.green.withValues(alpha: 0.15)
                              : OpenAITheme.gray200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle : Icons.today,
                          size: 28,
                          color: isCompleted ? OpenAITheme.green : OpenAITheme.gray700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCompleted ? '今日挑战已完成' : '每日挑战',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? OpenAITheme.green : OpenAITheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCompleted
                                  ? '得分: ${challenge?.score ?? 0} 分'
                                  : '10道题 · 混合难度',
                              style: TextStyle(
                                fontSize: 14,
                                color: isCompleted
                                    ? OpenAITheme.green.withValues(alpha: 0.8)
                                    : OpenAITheme.gray500,
                              ),
                            ),
                            if (!isCompleted)
                              challengeStreakAsync.when(
                                data: (streak) => streak > 0
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.local_fire_department,
                                              size: 14,
                                              color: OpenAITheme.gray500,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '连续 $streak 天',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: OpenAITheme.gray500,
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
                        const Icon(
                          Icons.chevron_right,
                          color: OpenAITheme.gray400,
                        ),
                    ],
                  ),
                );
              },
              loading: () => OCard(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: CircularProgressIndicator(color: OpenAITheme.gray900),
                ),
              ),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            const OSectionHeader(title: '测验模式'),

            // 综合测验
            OCard(
              onTap: () => _showDifficultySheet(context, ref, QuizMode.comprehensive),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: OpenAITheme.gray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.quiz_outlined, color: OpenAITheme.gray700, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '综合测验',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: OpenAITheme.gray900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '词汇+语法混合练习',
                          style: TextStyle(
                            fontSize: 13,
                            color: OpenAITheme.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: OpenAITheme.gray400),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 错题集
            wrongCountAsync.when(
              data: (count) => OCard(
                onTap: count > 0
                    ? () => _startWrongQuestionsQuiz(context, ref)
                    : null,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: count > 0 ? OpenAITheme.redLight : OpenAITheme.gray100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: count > 0 ? OpenAITheme.red : OpenAITheme.gray400,
                            size: 24,
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: OpenAITheme.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: OpenAITheme.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '错题集',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: OpenAITheme.gray900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            count > 0 ? '$count 道错题待复习' : '暂无错题',
                            style: const TextStyle(
                              fontSize: 13,
                              color: OpenAITheme.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (count > 0)
                      const Icon(Icons.chevron_right, color: OpenAITheme.gray400),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // 统计信息
            quizStatsAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OSectionHeader(title: '我的统计'),
                  OCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: '完成测验',
                              value: '${stats['totalQuizzes']}',
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: OpenAITheme.gray200,
                            ),
                            _StatItem(
                              label: '平均分',
                              value: '${stats['avgScore'].toStringAsFixed(0)}',
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: OpenAITheme.gray200,
                            ),
                            _StatItem(
                              label: '最高分',
                              value: '${stats['maxScore']}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text(
                              '总正确率',
                              style: TextStyle(
                                fontSize: 14,
                                color: OpenAITheme.gray500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(stats['accuracy'] * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: OpenAITheme.gray900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        OProgressBar(
                          progress: stats['accuracy'],
                          height: 6,
                        ),
                      ],
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
        SnackBar(
          content: const Text('错题集为空'),
          backgroundColor: OpenAITheme.gray900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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

  void _showDifficultySheet(BuildContext context, WidgetRef ref, QuizMode mode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpenAITheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '选择难度',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.gray900,
              ),
            ),
            const SizedBox(height: 16),
            _DifficultyOption(
              title: '简单',
              subtitle: 'A1-A2 级别',
              onTap: () {
                Navigator.pop(context);
                _startComprehensiveQuiz(context, ref, QuizDifficulty.easy);
              },
            ),
            _DifficultyOption(
              title: '中等',
              subtitle: 'B1-B2 级别',
              onTap: () {
                Navigator.pop(context);
                _startComprehensiveQuiz(context, ref, QuizDifficulty.medium);
              },
            ),
            _DifficultyOption(
              title: '困难',
              subtitle: 'C1-C2 级别',
              onTap: () {
                Navigator.pop(context);
                _startComprehensiveQuiz(context, ref, QuizDifficulty.hard);
              },
            ),
            _DifficultyOption(
              title: '混合',
              subtitle: '所有级别',
              onTap: () {
                Navigator.pop(context);
                _startComprehensiveQuiz(context, ref, QuizDifficulty.mixed);
              },
            ),
            const SizedBox(height: 10),
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
    final questions = await ref.read(comprehensiveQuizProvider(difficulty).future);

    if (questions.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('该难度暂无题目'),
          backgroundColor: OpenAITheme.gray900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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

class _DifficultyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: OpenAITheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: OpenAITheme.gray500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: OpenAITheme.gray400),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: OpenAITheme.gray900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: OpenAITheme.gray500,
          ),
        ),
      ],
    );
  }
}
