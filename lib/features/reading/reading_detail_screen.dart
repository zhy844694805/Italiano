import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/reading.dart';
import '../../shared/providers/reading_provider.dart';

class ReadingDetailScreen extends ConsumerStatefulWidget {
  final ReadingPassage passage;

  const ReadingDetailScreen({super.key, required this.passage});

  @override
  ConsumerState<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends ConsumerState<ReadingDetailScreen> {
  final Map<String, String> _userAnswers = {};
  bool _showResults = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    // 加载已有答案
    final progress = ref.read(readingProgressProvider)[widget.passage.id];
    if (progress != null) {
      _userAnswers.addAll(progress.userAnswers);
      _showResults = true;
      _correctCount = progress.correctAnswers;
    }
  }

  void _submitAnswers() {
    setState(() {
      _showResults = true;
      _correctCount = 0;

      // 计算正确答案数
      for (var question in widget.passage.questions) {
        if (_userAnswers[question.id] == question.answer) {
          _correctCount++;
        }
      }
    });

    // 保存到数据库
    ref.read(readingProgressProvider.notifier).saveResult(
          passageId: widget.passage.id,
          userAnswers: _userAnswers,
          correctAnswers: _correctCount,
          totalQuestions: widget.passage.questions.length,
        );

    // 显示结果对话框
    _showResultDialog();
  }

  void _showResultDialog() {
    final accuracy = _correctCount / widget.passage.questions.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完成！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              accuracy >= 0.8 ? Icons.celebration : Icons.thumb_up,
              size: 64,
              color: accuracy >= 0.8 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              '正确率: ${(accuracy * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount / ${widget.passage.questions.length} 题正确',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('查看详情'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('返回列表'),
          ),
        ],
      ),
    );
  }

  void _resetAnswers() {
    setState(() {
      _userAnswers.clear();
      _showResults = false;
      _correctCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.passage.titleChinese),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_showResults)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetAnswers,
              tooltip: '重新答题',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文章信息
            _buildHeader(),

            // 文章正文
            _buildContent(),

            // 理解题
            _buildQuestions(),

            // 提交按钮
            if (!_showResults) _buildSubmitButton(),

            // 底部间距
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor(widget.passage.level),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.passage.level,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.passage.category,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.passage.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.passage.titleChinese,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.article, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${widget.passage.wordCount} 词', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('约 ${widget.passage.estimatedMinutes} 分钟', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 16),
              Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${widget.passage.questions.length} 题', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '文章',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            widget.passage.content,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '理解题',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...widget.passage.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionCard(index + 1, question);
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int number, ReadingQuestion question) {
    final userAnswer = _userAnswers[question.id];
    final isCorrect = userAnswer == question.answer;
    final showFeedback = _showResults && userAnswer != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: showFeedback
          ? (isCorrect ? Colors.green[50] : Colors.red[50])
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 题号和题目
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: showFeedback
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      showFeedback
                          ? (isCorrect ? '✓' : '✗')
                          : '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.questionItalian,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 选项
            if (question.options != null)
              ...question.options!.asMap().entries.map((entry) {
                final option = entry.value;
                final isSelected = userAnswer == option;
                final isCorrectAnswer = option == question.answer;

                return InkWell(
                  onTap: _showResults ? null : () {
                    setState(() {
                      _userAnswers[question.id] = option;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getOptionColor(isSelected, isCorrectAnswer, showFeedback),
                      border: Border.all(
                        color: _getOptionBorderColor(isSelected, isCorrectAnswer, showFeedback),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getOptionIcon(isSelected, isCorrectAnswer, showFeedback),
                          size: 20,
                          color: _getOptionIconColor(isSelected, isCorrectAnswer, showFeedback),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 15,
                              color: _getOptionTextColor(isSelected, isCorrectAnswer, showFeedback),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            // 答案解释
            if (showFeedback) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          '答案解析',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '正确答案: ${question.answer}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.explanation,
                      style: const TextStyle(fontSize: 14),
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

  Color _getOptionColor(bool isSelected, bool isCorrectAnswer, bool showFeedback) {
    if (!showFeedback) {
      return isSelected ? Colors.blue[100]! : Colors.white;
    }
    if (isCorrectAnswer) return Colors.green[100]!;
    if (isSelected && !isCorrectAnswer) return Colors.red[100]!;
    return Colors.white;
  }

  Color _getOptionBorderColor(bool isSelected, bool isCorrectAnswer, bool showFeedback) {
    if (!showFeedback) {
      return isSelected ? Colors.blue : Colors.grey[300]!;
    }
    if (isCorrectAnswer) return Colors.green;
    if (isSelected && !isCorrectAnswer) return Colors.red;
    return Colors.grey[300]!;
  }

  IconData _getOptionIcon(bool isSelected, bool isCorrectAnswer, bool showFeedback) {
    if (!showFeedback) {
      return isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked;
    }
    if (isCorrectAnswer) return Icons.check_circle;
    if (isSelected && !isCorrectAnswer) return Icons.cancel;
    return Icons.radio_button_unchecked;
  }

  Color _getOptionIconColor(bool isSelected, bool isCorrectAnswer, bool showFeedback) {
    if (!showFeedback) {
      return isSelected ? Colors.blue : Colors.grey;
    }
    if (isCorrectAnswer) return Colors.green;
    if (isSelected && !isCorrectAnswer) return Colors.red;
    return Colors.grey;
  }

  Color _getOptionTextColor(bool isSelected, bool isCorrectAnswer, bool showFeedback) {
    if (!showFeedback) {
      return Colors.black87;
    }
    if (isCorrectAnswer) return Colors.green[900]!;
    if (isSelected && !isCorrectAnswer) return Colors.red[900]!;
    return Colors.black87;
  }

  Widget _buildSubmitButton() {
    final allAnswered = widget.passage.questions.every((q) => _userAnswers.containsKey(q.id));

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: allAnswered ? _submitAnswers : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            allAnswered ? '提交答案' : '请完成所有题目',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return Colors.green;
      case 'A2':
        return Colors.blue;
      case 'B1':
        return Colors.orange;
      case 'B2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
