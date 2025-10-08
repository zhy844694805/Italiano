import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/quiz.dart';
import 'package:confetti/confetti.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final QuizSession session;

  const QuizResultScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // 如果得分>=80,播放庆祝动画
    if (widget.session.score >= 80) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final session = widget.session;

    final scoreColor = _getScoreColor(session.score);
    final feedback = _getScoreFeedback(session.score);

    return Scaffold(
      appBar: AppBar(
        title: const Text('测验结果'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 分数卡片
                Card(
                  color: scoreColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          _getScoreIcon(session.score),
                          size: 80,
                          color: scoreColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${session.score}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                            fontSize: 72,
                          ),
                        ),
                        Text(
                          '分',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: scoreColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          feedback,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 统计信息
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: '正确',
                        value: '${session.correctCount}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.cancel,
                        label: '错误',
                        value: '${session.totalQuestions - session.correctCount}',
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.percent,
                        label: '正确率',
                        value: '${(session.accuracy * 100).toStringAsFixed(1)}%',
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer,
                        label: '用时',
                        value: _formatDuration(
                          session.completedAt!.difference(session.startedAt),
                        ),
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 答题回顾
                Text(
                  '答题回顾',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                ...session.questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  final result = session.results[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuestionReviewCard(
                      questionNumber: index + 1,
                      question: question,
                      result: result,
                    ),
                  );
                }),

                const SizedBox(height: 80), // 底部留白
              ],
            ),
          ),

          // 庆祝动画
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('返回首页'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    // TODO: 再来一次
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('再来一次'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 90) return Icons.emoji_events;
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  String _getScoreFeedback(int score) {
    if (score >= 90) return '优秀!继续保持!';
    if (score >= 80) return '很好!再接再厉!';
    if (score >= 60) return '不错!还有提升空间!';
    return '继续努力!多加练习!';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes分${seconds}秒';
    }
    return '$seconds秒';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionReviewCard extends StatelessWidget {
  final int questionNumber;
  final QuizQuestion question;
  final QuizResult result;

  const _QuestionReviewCard({
    required this.questionNumber,
    required this.question,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCorrect = result.isCorrect;

    return Card(
      color: isCorrect
          ? Colors.green.withValues(alpha: 0.05)
          : Colors.red.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$questionNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
                const Spacer(),
                _TypeChip(
                  label: _getTypeLabel(question.type),
                  color: _getTypeColor(question.type),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (!isCorrect) ...[
              Row(
                children: [
                  Icon(Icons.close, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '你的答案: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      result.userAnswer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '正确答案: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: Text(
                    question.correctAnswer,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (question.explanation != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(QuizType type) {
    switch (type) {
      case QuizType.vocabulary:
        return '词汇';
      case QuizType.grammar:
        return '语法';
      case QuizType.translation:
        return '翻译';
      case QuizType.listening:
        return '听力';
    }
  }

  Color _getTypeColor(QuizType type) {
    switch (type) {
      case QuizType.vocabulary:
        return Colors.blue;
      case QuizType.grammar:
        return Colors.green;
      case QuizType.translation:
        return Colors.purple;
      case QuizType.listening:
        return Colors.orange;
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
