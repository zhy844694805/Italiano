import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/grammar.dart';
import '../../shared/providers/grammar_provider.dart';
import '../../shared/providers/achievement_provider.dart';
import '../../shared/widgets/achievement_unlock_dialog.dart';
import '../../core/theme/openai_theme.dart';

class GrammarDetailScreen extends ConsumerStatefulWidget {
  final GrammarPoint grammarPoint;

  const GrammarDetailScreen({
    super.key,
    required this.grammarPoint,
  });

  @override
  ConsumerState<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends ConsumerState<GrammarDetailScreen> {
  int _currentStep = 0; // 0: 规则, 1: 例句, 2: 练习
  int _currentExerciseIndex = 0;
  final Map<String, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    // 标记为已学习
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(grammarProgressProvider.notifier).markAsStudied(widget.grammarPoint.id);
    });
  }

  Future<void> _markAsCompleted() async {
    ref.read(grammarProgressProvider.notifier).markAsCompleted(widget.grammarPoint.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已标记为完成'),
        backgroundColor: OpenAITheme.openaiGreen,
      ),
    );
    // 检查成就解锁
    final achievement = await checkAchievements(ref);
    if (achievement != null && mounted) {
      await AchievementUnlockDialog.show(context, achievement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(grammarProgressProvider)[widget.grammarPoint.id];
    final isCompleted = progress?.completed ?? false;

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: Text(widget.grammarPoint.title),
        actions: [
          if (!isCompleted)
            TextButton(
              onPressed: () => _markAsCompleted(),
              child: const Text(
                '完成',
                style: TextStyle(color: OpenAITheme.openaiGreen),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 步骤指示器
          _buildStepIndicator(),

          // 内容区域
          Expanded(
            child: _currentStep == 0
                ? _buildRulesView()
                : _currentStep == 1
                    ? _buildExamplesView()
                    : _buildExercisesView(),
          ),

          // 底部导航
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepDot(0, '规则'),
          _buildStepLine(0),
          _buildStepDot(1, '例句'),
          if (widget.grammarPoint.exercises.isNotEmpty) ...[
            _buildStepLine(1),
            _buildStepDot(2, '练习'),
          ],
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (step == 2 && widget.grammarPoint.exercises.isEmpty) return;
          setState(() => _currentStep = step);
        },
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? OpenAITheme.openaiGreen : OpenAITheme.bgSecondary,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: OpenAITheme.openaiGreen, width: 2)
                    : null,
              ),
              child: Center(
                child: isActive && !isCurrent
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        '${step + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : OpenAITheme.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isCurrent ? OpenAITheme.openaiGreen : OpenAITheme.textTertiary,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? OpenAITheme.openaiGreen : OpenAITheme.borderLight,
    );
  }

  // ========== 规则页面 ==========
  Widget _buildRulesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 简介卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OpenAITheme.openaiGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: OpenAITheme.openaiGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.grammarPoint.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: OpenAITheme.textPrimary,
                      height: 1.5,
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
            return _buildRuleCard(index, rule);
          }),
        ],
      ),
    );
  }

  Widget _buildRuleCard(int index, GrammarRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: OpenAITheme.bgSecondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rule.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 内容
          Text(
            rule.content,
            style: const TextStyle(
              fontSize: 14,
              color: OpenAITheme.textSecondary,
              height: 1.6,
            ),
          ),

          // 要点列表
          if (rule.points != null && rule.points!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: OpenAITheme.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rule.points!.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: OpenAITheme.openaiGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 13,
                            color: OpenAITheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========== 例句页面 ==========
  Widget _buildExamplesView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.grammarPoint.examples.length,
      itemBuilder: (context, index) {
        final example = widget.grammarPoint.examples[index];
        return _buildExampleCard(index, example);
      },
    );
  }

  Widget _buildExampleCard(int index, GrammarExample example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 例句序号
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: OpenAITheme.bgSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '例 ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textSecondary,
                  ),
                ),
              ),
              if (example.highlight != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    example.highlight!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.openaiGreen,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // 意大利语
          Text(
            example.italian,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // 中文翻译
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: OpenAITheme.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              example.chinese,
              style: const TextStyle(
                fontSize: 14,
                color: OpenAITheme.textSecondary,
              ),
            ),
          ),

          // 英文翻译（如果有）
          if (example.english != null) ...[
            const SizedBox(height: 8),
            Text(
              example.english!,
              style: const TextStyle(
                fontSize: 13,
                color: OpenAITheme.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========== 练习页面 ==========
  Widget _buildExercisesView() {
    if (widget.grammarPoint.exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.quiz_outlined, size: 48, color: OpenAITheme.textTertiary),
            SizedBox(height: 12),
            Text(
              '暂无练习题',
              style: TextStyle(
                fontSize: 16,
                color: OpenAITheme.textSecondary,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进度显示
          Row(
            children: [
              Text(
                '第 ${_currentExerciseIndex + 1} 题 / ${widget.grammarPoint.exercises.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentExerciseIndex = 0;
                    _userAnswers.clear();
                  });
                },
                child: const Text(
                  '重置',
                  style: TextStyle(color: OpenAITheme.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 进度条
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: OpenAITheme.gray100,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentExerciseIndex + 1) / widget.grammarPoint.exercises.length,
              child: Container(
                decoration: BoxDecoration(
                  color: OpenAITheme.openaiGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 题型标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: OpenAITheme.bgSecondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getExerciseTypeName(exercise.type),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 题目
                Text(
                  exercise.question,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // 选项
                if (exercise.type == 'choice' && exercise.options != null)
                  ...exercise.options!.map((option) {
                    final isSelected = userAnswer == option;
                    final isCorrectOption = option == exercise.answer;

                    Color bgColor = OpenAITheme.bgSecondary;
                    Color borderColor = Colors.transparent;

                    if (hasAnswered) {
                      if (isCorrectOption) {
                        bgColor = OpenAITheme.openaiGreen.withValues(alpha: 0.1);
                        borderColor = OpenAITheme.openaiGreen;
                      } else if (isSelected && !isCorrect) {
                        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
                        borderColor = const Color(0xFFEF4444);
                      }
                    } else if (isSelected) {
                      borderColor = OpenAITheme.openaiGreen;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: hasAnswered ? null : () {
                            setState(() {
                              _userAnswers[exercise.id] = option;
                            });
                            _checkAnswer(exercise, option);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor, width: borderColor == Colors.transparent ? 0 : 2),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: OpenAITheme.textPrimary,
                                    ),
                                  ),
                                ),
                                if (hasAnswered && isCorrectOption)
                                  const Icon(Icons.check_circle, color: OpenAITheme.openaiGreen, size: 20),
                                if (hasAnswered && isSelected && !isCorrect)
                                  const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                else
                  // 填空题输入框
                  TextField(
                    decoration: InputDecoration(
                      hintText: '请输入答案',
                      hintStyle: const TextStyle(color: OpenAITheme.textTertiary),
                      filled: true,
                      fillColor: OpenAITheme.bgSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: OpenAITheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: OpenAITheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: OpenAITheme.openaiGreen),
                      ),
                      suffixIcon: hasAnswered
                          ? Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? OpenAITheme.openaiGreen : const Color(0xFFEF4444),
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
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '解析',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF59E0B),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.explanation!,
                                style: const TextStyle(
                                  color: OpenAITheme.textPrimary,
                                  fontSize: 13,
                                  height: 1.4,
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
          const SizedBox(height: 16),

          // 题目导航按钮
          Row(
            children: [
              if (_currentExerciseIndex > 0)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _currentExerciseIndex--),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: OpenAITheme.borderLight),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, color: OpenAITheme.textSecondary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              '上一题',
                              style: TextStyle(
                                color: OpenAITheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_currentExerciseIndex > 0 && _currentExerciseIndex < widget.grammarPoint.exercises.length - 1)
                const SizedBox(width: 12),
              if (_currentExerciseIndex < widget.grammarPoint.exercises.length - 1)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasAnswered ? () => setState(() => _currentExerciseIndex++) : null,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: hasAnswered ? OpenAITheme.openaiGreen : OpenAITheme.gray100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '下一题',
                              style: TextStyle(
                                color: hasAnswered ? Colors.white : OpenAITheme.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              color: hasAnswered ? Colors.white : OpenAITheme.textTertiary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== 底部导航 ==========
  Widget _buildBottomNavigation() {
    final maxStep = widget.grammarPoint.exercises.isEmpty ? 1 : 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: OpenAITheme.white,
        border: Border(top: BorderSide(color: OpenAITheme.borderLight)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _currentStep--),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: OpenAITheme.borderLight),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, color: OpenAITheme.textSecondary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '上一步',
                          style: TextStyle(
                            color: OpenAITheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0 && _currentStep < maxStep)
            const SizedBox(width: 12),
          if (_currentStep < maxStep)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _currentStep++),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: OpenAITheme.openaiGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 0 ? '看例句' : '做练习',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep == maxStep)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: OpenAITheme.openaiGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '完成学习',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
        content: Text(isCorrect ? '回答正确！' : '回答错误，正确答案是: ${exercise.answer}'),
        backgroundColor: isCorrect ? OpenAITheme.openaiGreen : const Color(0xFFF59E0B),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
