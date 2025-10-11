import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/grammar.dart';
import '../../shared/providers/grammar_provider.dart';
import '../../core/theme/modern_theme.dart';
import '../../shared/widgets/gradient_card.dart';

class GrammarDetailScreen extends ConsumerStatefulWidget {
  final GrammarPoint grammarPoint;

  const GrammarDetailScreen({
    super.key,
    required this.grammarPoint,
  });

  @override
  ConsumerState<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends ConsumerState<GrammarDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentExerciseIndex = 0;
  Map<String, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.grammarPoint.exercises.isEmpty ? 2 : 3, vsync: this);

    // 标记为已学习
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(grammarProgressProvider.notifier).markAsStudied(widget.grammarPoint.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = ref.watch(grammarProgressProvider)[widget.grammarPoint.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grammarPoint.title),
        actions: [
          IconButton(
            icon: Icon(
              progress?.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
              color: progress?.isFavorite ?? false ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(grammarProgressProvider.notifier).toggleFavorite(widget.grammarPoint.id);
            },
          ),
          if (!(progress?.completed ?? false))
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: '标记为已完成',
              onPressed: () {
                ref.read(grammarProgressProvider.notifier).markAsCompleted(widget.grammarPoint.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ 已标记为完成')),
                );
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.menu_book), text: '规则'),
            const Tab(icon: Icon(Icons.lightbulb_outline), text: '例句'),
            if (widget.grammarPoint.exercises.isNotEmpty)
              const Tab(icon: Icon(Icons.quiz_outlined), text: '练习'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRulesTab(theme, colorScheme),
          _buildExamplesTab(theme, colorScheme),
          if (widget.grammarPoint.exercises.isNotEmpty)
            _buildExercisesTab(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildRulesTab(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 描述
          Container(
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ModernTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.grammarPoint.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 规则列表
          ...widget.grammarPoint.rules.asMap().entries.map((entry) {
            final index = entry.key;
            final rule = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: ModernTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rule.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rule.content,
                            style: theme.textTheme.bodyLarge,
                          ),
                          if (rule.points != null && rule.points!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...rule.points!.map((point) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExamplesTab(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.grammarPoint.examples.length,
      itemBuilder: (context, index) {
        final example = widget.grammarPoint.examples[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: ModernTheme.secondaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '例 ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 意大利语
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        example.italian,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 中文
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.translate, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        example.chinese,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
                if (example.english != null) ...[
                  const SizedBox(height: 8),
                  // 英语
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.language, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          example.english!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (example.highlight != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.highlight, color: colorScheme.tertiary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '重点: ${example.highlight}',
                          style: TextStyle(
                            color: colorScheme.onTertiaryContainer,
                            fontSize: 12,
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
      },
    );
  }

  Widget _buildExercisesTab(ThemeData theme, ColorScheme colorScheme) {
    if (widget.grammarPoint.exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              '暂无练习题',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    final exercise = widget.grammarPoint.exercises[_currentExerciseIndex];
    final userAnswer = _userAnswers[exercise.id];
    final hasAnswered = userAnswer != null;
    final isCorrect = hasAnswered && userAnswer == exercise.answer;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 进度指示器
          Row(
            children: [
              Text(
                '${_currentExerciseIndex + 1} / ${widget.grammarPoint.exercises.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _currentExerciseIndex = 0;
                    _userAnswers.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重置'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GradientProgressBar(
            progress: (_currentExerciseIndex + 1) / widget.grammarPoint.exercises.length,
            height: 8,
            gradient: ModernTheme.primaryGradient,
          ),
          const SizedBox(height: 24),

          // 题目卡片
          Expanded(
            child: SingleChildScrollView(
              child: FloatingCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 题型标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: ModernTheme.accentGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getExerciseTypeName(exercise.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                      const SizedBox(height: 16),

                      // 题目
                      Text(
                        exercise.question,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 选项或输入框
                      if (exercise.type == 'choice' && exercise.options != null)
                        ...exercise.options!.map((option) {
                          final isSelected = userAnswer == option;
                          final showResult = hasAnswered;
                          final isCorrectOption = option == exercise.answer;

                          Color? cardColor;
                          if (showResult) {
                            if (isSelected && isCorrect) {
                              cardColor = Colors.green.withValues(alpha: 0.1);
                            } else if (isSelected && !isCorrect) {
                              cardColor = Colors.red.withValues(alpha: 0.1);
                            } else if (isCorrectOption) {
                              cardColor = Colors.green.withValues(alpha: 0.1);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: hasAnswered ? null : () {
                                setState(() {
                                  _userAnswers[exercise.id] = option;
                                });
                                _checkAnswer(exercise, option);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor ?? colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                    if (showResult && isCorrectOption)
                                      const Icon(Icons.check_circle, color: Colors.green),
                                    if (showResult && isSelected && !isCorrect)
                                      const Icon(Icons.cancel, color: Colors.red),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                      else
                        TextField(
                          decoration: InputDecoration(
                            hintText: '请输入答案',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: hasAnswered
                                ? Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? Colors.green : Colors.red,
                                  )
                                : null,
                          ),
                          enabled: !hasAnswered,
                          onSubmitted: (value) {
                            setState(() {
                              _userAnswers[exercise.id] = value;
                            });
                            _checkAnswer(exercise, value);
                          },
                        ),

                      // 解析
                      if (hasAnswered && exercise.explanation != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb, color: colorScheme.tertiary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '解析',
                                      style: TextStyle(
                                        color: colorScheme.onTertiaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      exercise.explanation!,
                                      style: TextStyle(
                                        color: colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // 导航按钮
          const SizedBox(height: 16),
          Row(
            children: [
              if (_currentExerciseIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentExerciseIndex--;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('上一题'),
                  ),
                ),
              if (_currentExerciseIndex > 0 && _currentExerciseIndex < widget.grammarPoint.exercises.length - 1)
                const SizedBox(width: 16),
              if (_currentExerciseIndex < widget.grammarPoint.exercises.length - 1)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasAnswered
                        ? () {
                            setState(() {
                              _currentExerciseIndex++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('下一题'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getExerciseTypeName(String type) {
    switch (type) {
      case 'choice':
        return '选择题';
      case 'fill_blank':
        return '填空题';
      case 'translation':
        return '翻译题';
      default:
        return '练习题';
    }
  }

  void _checkAnswer(GrammarExercise exercise, String answer) {
    final isCorrect = answer.trim().toLowerCase() == exercise.answer.trim().toLowerCase();

    // 记录练习结果
    ref.read(grammarProgressProvider.notifier).recordExerciseResult(widget.grammarPoint.id, isCorrect);

    // 显示反馈
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? '✓ 回答正确！' : '✗ 回答错误，正确答案是: ${exercise.answer}'),
        backgroundColor: isCorrect ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
