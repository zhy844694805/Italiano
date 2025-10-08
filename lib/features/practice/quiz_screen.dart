import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/quiz.dart';
import '../../shared/providers/quiz_provider.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;

  const QuizScreen({
    super.key,
    required this.mode,
    required this.difficulty,
    required this.questions,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  String? _selectedAnswer;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    // 开始测验
    Future.microtask(() {
      ref.read(currentQuizSessionProvider.notifier).startQuiz(
            mode: widget.mode,
            difficulty: widget.difficulty,
            questions: widget.questions,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final session = ref.watch(currentQuizSessionProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('测验')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion =
        ref.read(currentQuizSessionProvider.notifier).getCurrentQuestion();

    if (currentQuestion == null) {
      // 测验完成,导航到结果页
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(session: session),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentIndex = session.results.length + 1;
    final progress = currentIndex / session.totalQuestions;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getModeTitle()),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$currentIndex / ${session.totalQuestions}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 进度条
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 题目类型标签
                    Row(
                      children: [
                        _TypeChip(
                          label: _getTypeLabel(currentQuestion.type),
                          color: _getTypeColor(currentQuestion.type),
                        ),
                        const SizedBox(width: 8),
                        _TypeChip(
                          label: currentQuestion.level,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 题目文本
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          currentQuestion.question,
                          style: theme.textTheme.titleLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 提示(如果有)
                    if (currentQuestion.hint != null && !_showExplanation)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentQuestion.hint!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 选项
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      final option = entry.value;
                      final isSelected = _selectedAnswer == option;
                      final isCorrect = option == currentQuestion.correctAnswer;
                      final showResult = _showExplanation;

                      Color? backgroundColor;
                      Color? borderColor;
                      IconData? icon;

                      if (showResult) {
                        if (isCorrect) {
                          backgroundColor = Colors.green.withValues(alpha: 0.1);
                          borderColor = Colors.green;
                          icon = Icons.check_circle;
                        } else if (isSelected && !isCorrect) {
                          backgroundColor = Colors.red.withValues(alpha: 0.1);
                          borderColor = Colors.red;
                          icon = Icons.cancel;
                        }
                      } else if (isSelected) {
                        backgroundColor = colorScheme.primaryContainer;
                        borderColor = colorScheme.primary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OptionCard(
                          option: option,
                          isSelected: isSelected,
                          backgroundColor: backgroundColor,
                          borderColor: borderColor,
                          icon: icon,
                          onTap: !_showExplanation
                              ? () {
                                  setState(() {
                                    _selectedAnswer = option;
                                  });
                                }
                              : null,
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // 解析(答题后显示)
                    if (_showExplanation && currentQuestion.explanation != null)
                      Card(
                        color: colorScheme.tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: colorScheme.onTertiaryContainer,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '解析',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentQuestion.explanation!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 底部按钮
            Container(
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
                child: _showExplanation
                    ? FilledButton(
                        onPressed: _nextQuestion,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(
                          currentIndex == session.totalQuestions
                              ? '查看结果'
                              : '下一题',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : FilledButton(
                        onPressed: _selectedAnswer != null ? _submitAnswer : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          '提交答案',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case QuizMode.daily:
        return '每日挑战';
      case QuizMode.comprehensive:
        return '综合测验';
      case QuizMode.wrongQuestions:
        return '错题集';
      case QuizMode.custom:
        return '自定义测验';
    }
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

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    final currentQuestion =
        ref.read(currentQuizSessionProvider.notifier).getCurrentQuestion();
    if (currentQuestion == null) return;

    // 提交答案
    ref.read(currentQuizSessionProvider.notifier).submitAnswer(
          currentQuestion.id,
          _selectedAnswer!,
        );

    // 显示解析
    setState(() {
      _showExplanation = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _selectedAnswer = null;
      _showExplanation = false;
    });
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出测验?'),
        content: const Text('当前进度将不会保存'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('继续答题'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentQuizSessionProvider.notifier).reset();
              Navigator.pop(context, true);
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String option;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 2 : 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor ?? Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: borderColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
