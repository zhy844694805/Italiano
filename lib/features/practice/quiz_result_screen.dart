import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/quiz.dart';
import '../../core/theme/openai_theme.dart';
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
    final session = widget.session;
    final scoreColor = _getScoreColor(session.score);
    final feedback = _getScoreFeedback(session.score);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
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
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: OpenAITheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OpenAITheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      // 图标
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getScoreIcon(session.score),
                          size: 40,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 分数
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${session.score}',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              color: scoreColor,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '分',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: scoreColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 评价
                      Text(
                        feedback,
                        style: const TextStyle(
                          fontSize: 16,
                          color: OpenAITheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 统计信息
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_outline,
                        label: '正确',
                        value: '${session.correctCount}',
                        color: OpenAITheme.openaiGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.cancel_outlined,
                        label: '错误',
                        value: '${session.totalQuestions - session.correctCount}',
                        color: OpenAITheme.error,
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
                        value: '${(session.accuracy * 100).toStringAsFixed(0)}%',
                        color: OpenAITheme.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer_outlined,
                        label: '用时',
                        value: _formatDuration(
                          session.completedAt!.difference(session.startedAt),
                        ),
                        color: OpenAITheme.gray500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 答题回顾标题
                const Text(
                  '答题回顾',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '点击查看每道题的详细解析',
                  style: TextStyle(
                    fontSize: 13,
                    color: OpenAITheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),

                // 题目回顾列表
                ...session.questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  final result = session.results[index];

                  return _QuestionReviewCard(
                    questionNumber: index + 1,
                    question: question,
                    result: result,
                  );
                }),

                const SizedBox(height: 80),
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
                OpenAITheme.openaiGreen,
                OpenAITheme.info,
                OpenAITheme.warning,
                Color(0xFF8B5CF6),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: OpenAITheme.white,
          border: Border(
            top: BorderSide(color: OpenAITheme.borderLight),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: OpenAITheme.borderMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '返回首页',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OpenAITheme.openaiGreen,
                    foregroundColor: OpenAITheme.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '再来一次',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return OpenAITheme.openaiGreen;
    if (score >= 80) return OpenAITheme.info;
    if (score >= 60) return OpenAITheme.warning;
    return OpenAITheme.error;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 90) return Icons.emoji_events_outlined;
    if (score >= 80) return Icons.sentiment_very_satisfied_outlined;
    if (score >= 60) return Icons.sentiment_satisfied_outlined;
    return Icons.sentiment_dissatisfied_outlined;
  }

  String _getScoreFeedback(int score) {
    if (score >= 90) return '太棒了！你已经掌握得很好了';
    if (score >= 80) return '做得不错！继续保持';
    if (score >= 60) return '还不错，再努力一下';
    return '继续加油，多练习会更好';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes分$seconds秒';
    }
    return '$seconds秒';
  }
}

// 统计卡片
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
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
      ),
    );
  }
}

// 题目回顾卡片
class _QuestionReviewCard extends StatefulWidget {
  final int questionNumber;
  final QuizQuestion question;
  final QuizResult result;

  const _QuestionReviewCard({
    required this.questionNumber,
    required this.question,
    required this.result,
  });

  @override
  State<_QuestionReviewCard> createState() => _QuestionReviewCardState();
}

class _QuestionReviewCardState extends State<_QuestionReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.result.isCorrect;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        children: [
          // 头部 - 可点击展开
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 题号
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? OpenAITheme.openaiGreen.withValues(alpha: 0.1)
                            : OpenAITheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.questionNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCorrect ? OpenAITheme.openaiGreen : OpenAITheme.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 题目预览
                    Expanded(
                      child: Text(
                        widget.question.question,
                        style: const TextStyle(
                          fontSize: 14,
                          color: OpenAITheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 对错图标
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 20,
                      color: isCorrect ? OpenAITheme.openaiGreen : OpenAITheme.error,
                    ),
                    const SizedBox(width: 8),

                    // 展开图标
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: OpenAITheme.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 展开内容
          if (_expanded) ...[
            const Divider(height: 1, color: OpenAITheme.borderLight),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 完整题目
                  Text(
                    widget.question.question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: OpenAITheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 你的答案（如果错了）
                  if (!isCorrect) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.close,
                          size: 16,
                          color: OpenAITheme.error,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '你的答案: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: OpenAITheme.error,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.result.userAnswer,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: OpenAITheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 正确答案
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: OpenAITheme.openaiGreen,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '正确答案: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: OpenAITheme.openaiGreen,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.question.correctAnswer,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: OpenAITheme.openaiGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 解析
                  if (widget.question.explanation != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: OpenAITheme.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: OpenAITheme.textTertiary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.question.explanation!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: OpenAITheme.textSecondary,
                                height: 1.5,
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
          ],
        ],
      ),
    );
  }
}
