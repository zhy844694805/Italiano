import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/quiz.dart';
import '../../shared/providers/quiz_provider.dart';
import '../../core/theme/openai_theme.dart';
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
  final TextEditingController _fillInController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(currentQuizSessionProvider.notifier).startQuiz(
            mode: widget.mode,
            difficulty: widget.difficulty,
            questions: widget.questions,
          );
    });
  }

  @override
  void dispose() {
    _fillInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentQuizSessionProvider);

    if (session == null) {
      return Scaffold(
        backgroundColor: OpenAITheme.bgPrimary,
        appBar: AppBar(
          backgroundColor: OpenAITheme.bgPrimary,
          title: const Text('测验'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
        ),
      );
    }

    final currentQuestion =
        ref.read(currentQuizSessionProvider.notifier).getCurrentQuestion();

    if (currentQuestion == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(session: session),
          ),
        );
      });
      return Scaffold(
        backgroundColor: OpenAITheme.bgPrimary,
        body: const Center(
          child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
        ),
      );
    }

    final currentIndex = session.results.length + 1;
    final progress = currentIndex / session.totalQuestions;
    final isFillInBlank = currentQuestion.options.isEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog(context);
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: OpenAITheme.bgPrimary,
        appBar: AppBar(
          backgroundColor: OpenAITheme.bgPrimary,
          title: Text(_getModeTitle()),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: OpenAITheme.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$currentIndex / ${session.totalQuestions}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 进度条
            Container(
              height: 4,
              color: OpenAITheme.gray100,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(color: OpenAITheme.openaiGreen),
              ),
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
                        _TypeTag(
                          label: _getTypeLabel(currentQuestion.type),
                          color: _getTypeColor(currentQuestion.type),
                        ),
                        const SizedBox(width: 8),
                        _TypeTag(
                          label: currentQuestion.level,
                          color: OpenAITheme.gray500,
                        ),
                        const SizedBox(width: 8),
                        _TypeTag(
                          label: isFillInBlank ? '填空' : '选择',
                          color: OpenAITheme.info,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 题目卡片
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: OpenAITheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: OpenAITheme.borderLight),
                      ),
                      child: Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: OpenAITheme.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 提示
                    if (currentQuestion.hint != null && !_showExplanation)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: OpenAITheme.warning.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: OpenAITheme.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: OpenAITheme.warning,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                currentQuestion.hint!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: OpenAITheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 填空题输入框 或 选择题选项
                    if (isFillInBlank)
                      _buildFillInBlankInput(currentQuestion)
                    else
                      ...currentQuestion.options.map((option) {
                        final isSelected = _selectedAnswer == option;
                        final isCorrect = option == currentQuestion.correctAnswer;
                        final showResult = _showExplanation;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OptionCard(
                            option: option,
                            isSelected: isSelected,
                            isCorrect: isCorrect,
                            showResult: showResult,
                            onTap: !_showExplanation
                                ? () => setState(() => _selectedAnswer = option)
                                : null,
                          ),
                        );
                      }),

                    // 解析
                    if (_showExplanation && currentQuestion.explanation != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: OpenAITheme.bgSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: OpenAITheme.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: OpenAITheme.info.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: OpenAITheme.info,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  '解析',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: OpenAITheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentQuestion.explanation!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: OpenAITheme.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
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
                color: OpenAITheme.white,
                border: Border(
                  top: BorderSide(color: OpenAITheme.borderLight),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _showExplanation
                      ? ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OpenAITheme.openaiGreen,
                            foregroundColor: OpenAITheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            currentIndex == session.totalQuestions
                                ? '查看结果'
                                : '下一题',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _canSubmit(isFillInBlank) ? _submitAnswer : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSubmit(isFillInBlank)
                                ? OpenAITheme.openaiGreen
                                : OpenAITheme.gray200,
                            foregroundColor: _canSubmit(isFillInBlank)
                                ? OpenAITheme.white
                                : OpenAITheme.textTertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '提交答案',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建填空题输入区域
  Widget _buildFillInBlankInput(QuizQuestion question) {
    final isCorrect = _showExplanation &&
        _fillInController.text.trim().toLowerCase() ==
            question.correctAnswer.toLowerCase();
    final isWrong = _showExplanation && !isCorrect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 输入框
        Container(
          decoration: BoxDecoration(
            color: OpenAITheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _showExplanation
                  ? (isCorrect ? OpenAITheme.openaiGreen : OpenAITheme.error)
                  : OpenAITheme.borderLight,
              width: _showExplanation ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _fillInController,
            enabled: !_showExplanation,
            style: TextStyle(
              fontSize: 16,
              color: _showExplanation
                  ? (isCorrect ? OpenAITheme.openaiGreen : OpenAITheme.error)
                  : OpenAITheme.textPrimary,
              fontWeight: _showExplanation ? FontWeight.w600 : FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: '请输入你的答案...',
              hintStyle: const TextStyle(
                color: OpenAITheme.textTertiary,
                fontSize: 16,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              suffixIcon: _showExplanation
                  ? Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? OpenAITheme.openaiGreen : OpenAITheme.error,
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _selectedAnswer = value;
              });
            },
          ),
        ),

        // 显示正确答案（如果答错）
        if (isWrong) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: OpenAITheme.openaiGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: OpenAITheme.openaiGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: OpenAITheme.openaiGreen,
                ),
                const SizedBox(width: 10),
                const Text(
                  '正确答案: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: OpenAITheme.openaiGreen,
                  ),
                ),
                Expanded(
                  child: Text(
                    question.correctAnswer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.openaiGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _canSubmit(bool isFillInBlank) {
    if (isFillInBlank) {
      return _fillInController.text.trim().isNotEmpty;
    } else {
      return _selectedAnswer != null;
    }
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
        return OpenAITheme.info;
      case QuizType.grammar:
        return OpenAITheme.openaiGreen;
      case QuizType.translation:
        return const Color(0xFF8B5CF6);
      case QuizType.listening:
        return OpenAITheme.warning;
    }
  }

  void _submitAnswer() {
    final currentQuestion =
        ref.read(currentQuizSessionProvider.notifier).getCurrentQuestion();
    if (currentQuestion == null) return;

    final isFillInBlank = currentQuestion.options.isEmpty;
    final answer = isFillInBlank
        ? _fillInController.text.trim()
        : _selectedAnswer;

    if (answer == null || answer.isEmpty) return;

    ref.read(currentQuizSessionProvider.notifier).submitAnswer(
          currentQuestion.id,
          answer,
        );

    setState(() {
      _showExplanation = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _selectedAnswer = null;
      _showExplanation = false;
      _fillInController.clear();
    });
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OpenAITheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '退出测验?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: OpenAITheme.textPrimary,
          ),
        ),
        content: const Text(
          '当前进度将不会保存',
          style: TextStyle(
            fontSize: 14,
            color: OpenAITheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '继续答题',
              style: TextStyle(color: OpenAITheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentQuizSessionProvider.notifier).reset();
              Navigator.pop(context, true);
            },
            child: const Text(
              '退出',
              style: TextStyle(color: OpenAITheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// 类型标签
class _TypeTag extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeTag({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 选项卡片
class _OptionCard extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = OpenAITheme.white;
    Color borderColor = OpenAITheme.borderLight;
    Color textColor = OpenAITheme.textPrimary;
    IconData? icon;
    Color? iconColor;

    if (showResult) {
      if (isCorrect) {
        bgColor = OpenAITheme.openaiGreen.withValues(alpha: 0.08);
        borderColor = OpenAITheme.openaiGreen;
        textColor = OpenAITheme.openaiGreen;
        icon = Icons.check_circle;
        iconColor = OpenAITheme.openaiGreen;
      } else if (isSelected && !isCorrect) {
        bgColor = OpenAITheme.error.withValues(alpha: 0.08);
        borderColor = OpenAITheme.error;
        textColor = OpenAITheme.error;
        icon = Icons.cancel;
        iconColor = OpenAITheme.error;
      }
    } else if (isSelected) {
      bgColor = OpenAITheme.openaiGreen.withValues(alpha: 0.05);
      borderColor = OpenAITheme.openaiGreen;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: (isSelected || (showResult && isCorrect)) ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 12),
                Icon(icon, color: iconColor, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
